class Admin::DashboardController < Admin::BaseController
  def index
    add_breadcrumb 'Dashboard'
    @unread = Contact.unread.count
  end

  def settings; end

  def tasks
    @tasks = [
      { name: 'backup:terminal_logs', description: 'Run this task for check how logs are printed in terminal component' },
      { name: 'backup:album_and_attachments', description: 'Run all tasks to seed demo' },
      { name: 'csv:merge_albums', description: 'Get albums and galleries and merge them and update ids' },
      { name: 'backup:albums', description: 'From updated albums import blobs and attachments' },
      { name: 'backup:active_storage_blobs', description: 'Import Active Storage Blobs from blobs.csv' },
      { name: 'backup:active_storage_attachments', description: 'From imported attachments update ids' },
      { name: 'backup:undefined_orphan_attachments', description: 'Assign to undefined album the orphan attachments'}
    ]
  end

  def spaces
    @objects = fetch_s3_objects

    @headers = %w[etag key size last_modified storage_class file]

    items = params[:items] || 10
    page = params[:page] || 1
    sort_column = params[:sort] || 'last_modified'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @content = @objects.sort_by { |obj| obj.send(sort_column.to_sym) }
    @content.reverse! if sort_direction == 'desc'
    @pagy, @content = pagy_array(@content, items: items)
  end


  def execute_task
    @logs = []
    15.times do |i|
      @logs << "📜 #{i + 1} Lorem ipsum dolor sit amet, consectetur adipiscing elit. 🚀"
    end
    ActionCable.server.broadcast("task_logs_channel", { logs: @logs })
    puts "Transmitiendo logs: #{@logs.inspect}"
  end

  private

  def fetch_s3_objects
    objects = $redis.get('s3_objects')
    if objects.nil?
      objects = retrieve_s3_objects
      $redis.set('s3_objects', Marshal.dump(objects))
      $redis.expire('s3_objects', 3600) # expire in 1 hour
    else
      objects = Marshal.load(objects)
      Rails.logger.info '🔥 Using cached S3 objects'
    end
    objects
  end

  def retrieve_s3_objects
    s3 = Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:digital_ocean, :region),
      endpoint: Rails.application.credentials.dig(:digital_ocean, :endpoint),
      access_key_id: Rails.application.credentials.dig(:digital_ocean, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:digital_ocean, :secret_access_key),
      force_path_style: true
    )
    bucket_name = Rails.application.credentials.dig(:digital_ocean, :bucket)

    objects = []
    continuation_token = nil

    loop do
      response = s3.list_objects_v2(bucket: bucket_name, continuation_token: continuation_token)
      objects.concat(response.contents)
      break unless response.is_truncated
      continuation_token = response.next_continuation_token
    end

    objects
  end
end
