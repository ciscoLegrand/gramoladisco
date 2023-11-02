class UpdateImageCounterJob < ApplicationJob
  queue_as :default

  before_enqueue do |job|
    serialized_data = Sidekiq.dump_json(job.arguments)
    data_size = serialized_data.bytesize
    Rails.logger.info "Size of the enqueued data for AlbumImportJob: #{data_size} bytes"
  end

  def perform(album_id, host, current_user_id = nil)
    begin
      album = Album.find_by(id: album_id)
      album.current_host    = host
      album.current_user_id = current_user_id
      user_info = User.find_by(id: current_user_id)&.email if current_user_id.present?
      user_info = "System (background job): update_image_counter_job" if user_info.nil?

      return if album.counter == album.images.count

      Rails.logger.info "📀 Updating counter for Album (#{album.title})..."
      album.update! counter: album.images.count
    rescue => e
      Rails.logger.info "🚨 Error during the import process: #{e.message}"

      error_data = {
        process_name: "Error during update image counter for Album (#{album.title}) background job",
        end_time: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        environment: Rails.env,
        ruby_version: RUBY_VERSION,
        rails_version: Rails::VERSION::STRING,
        user: user_info,
        host_info: host,
        error_row: { album_title: album.title, error: e.message }
      }

      ErrorMailer.import_error({
        error_message: e.message,
        error_line: e.backtrace.first,
        error_data: error_data
      }).deliver_now
    end
  end
end
