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

  def execute_task
    @logs = []
    15.times do |i|
      @logs << "📜 #{i + 1} Lorem ipsum dolor sit amet, consectetur adipiscing elit. 🚀"
    end
    ActionCable.server.broadcast("task_logs_channel", { logs: @logs })
    puts "Transmitiendo logs: #{@logs.inspect}"

  end

  private

end
