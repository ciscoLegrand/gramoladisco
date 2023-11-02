class AlbumImportJob < ApplicationJob
  queue_as :high_priority_queue
  sidekiq_options retry: 1

  before_enqueue do |job|
    log_enqueue_data_size(job.arguments)
  end

  def perform(album_data)
    @start_time = Time.zone.now
    debug_log("Starting Album import for #{album_data[:album_title]} at #{@start_time}")

    album = Album.find_by(title: album_data[:album_title], password: album_data[:album_password])
    if album
      attach_blobs_to_existing_album(album, album_data[:blobs])
    else
      create_and_attach_album(album_data)
    end
  end

  private

  def create_and_attach_album(album_data)
    album = Album.new(
      title: album_data[:album_title],
      date_event: album_data[:album_date_event],
      password: album_data[:album_password],
      published_at: album_data[:album_date_event],
      emails: ['cisco.glez@gmail.com']
    )

    begin
      Album.transaction do
        album.save!
        attach_blobs_to_existing_album(album, album_data[:blobs])
        if album.images.count == album_data[:total_images]
          album.update!(counter: album.images.count, status: :publish)
          handle_successful_album_import(album, album_data, @start_time)
        end
      end
    rescue => e
      error_log("Error saving album: #{e.message}")
      set_error_info(e.message, e.backtrace.first, album_data)
      handle_failed_album_import(album, album_data)
      return [nil, {}] # Aquí aseguramos que se devuelva un array de dos elementos
    end

    album
  end

  def create_blobs_from_data(images_data)
    return [] unless images_data
    debug_log("#{images_data.first}")
    duplicated_blobs = []
  
    blobs = images_data.map do |blob_data|
      # next if ActiveStorage::Blob.exists?(key: blob_data['key'])

      begin
        ActiveStorage::Blob.create!(
          key: blob_data['key'],
          filename: blob_data['filename'],
          content_type: blob_data['content_type'],
          byte_size: blob_data['byte_size'].to_i,
          checksum: blob_data['checksum'],
          metadata: JSON.parse(blob_data['metadata'])
        )
      rescue ActiveRecord::RecordNotUnique => e
        Rails.logger.info "🔁 Blob #{blob_data['key']} already exists in album #{} due to race condition. Skipping...\n🎭🎭 #{e.message}" 
        duplicated_blobs << blob_data['key']
        nil
      end
    end.compact
    debug_log("#{blobs.first}")
    info_log("🔥🔥🔥#{blobs.size} blobs created and #{duplicated_blobs.size} duplicated blobs") unless blobs.nil?
    add_duplicated_blob_error(duplicated_blobs)
    blobs
  end

  def attach_blobs_to_existing_album(album, blobs_data)
    blobs = create_blobs_from_data(blobs_data)
    album.images.attach(blobs)
    album
  end
  
  def add_duplicated_blob_error(duplicated_blobs)
    return if duplicated_blobs.empty?

    error_message = "Duplicated blob keys detected: #{duplicated_blobs.join(', ')}"
    @error_info ||= {}
    @error_info[:duplicated_blob_keys] = error_message
  end

  def send_import_summary_email(album, start_time, end_time)
    info = {
      process_name: "Importación de ActiveStorage: #{album.title}",
      start_time: start_time.strftime('%Y-%m-%d %H:%M:%S'),
      end_time: end_time.strftime('%Y-%m-%d %H:%M:%S'),
      environment: Rails.env,
      ruby_version: RUBY_VERSION,
      rails_version: Rails::VERSION::STRING,
      user: "System (ActiveJob): AlbumImportJob",
      successful_albums: album.persisted? ? 1 : 0,
      failed_albums: album.persisted? ? 0 : 1,
      total_duration: end_time - start_time,
      errors: album.errors.full_messages
    }
    info_log("📧 Sending import summary email")
    ErrorMailer.import_summary(info).deliver_now
  end

  def set_error_info(message, backtrace_line, data)
    @error_info = {
      error_message: message,
      error_line: backtrace_line,
      error_data: data
    }
  end

  def send_import_error_email
    info_log("📧 Sending error email")
    ErrorMailer.import_error(@error_info).deliver_now
  end

  # Logging methods
  def log_enqueue_data_size(arguments)
    serialized_data = Sidekiq.dump_json(arguments)
    data_size = serialized_data.bytesize
    log_with_metadata("log_enque_before", "debug", "Size of the enqueued data for [AlbumImportJob]", {title: arguments[0][:album_title], size: "#{(data_size.to_f / 1_048_576).round(2)} MB"})
  end


  def handle_successful_album_import(album, album_data, start_time)
    return unless album.images.count == album_data[:total_images]
    
    info_log("Album #{album_data[:album_title]} imported successfully.")
    send_import_summary_email(album, start_time, Time.zone.now)
  end
  
  def handle_failed_album_import(album, album_data)
    error_log("Error importing album #{album_data[:album_title]}. Errors: #{album.errors.full_messages.join(', ')}")
    send_import_error_email if @error_info
  end
  
  def handle_unknown_error
    error_log("Unknown error during album import.")
    send_import_error_email if @error_info
  end
end
