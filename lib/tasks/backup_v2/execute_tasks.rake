namespace :backup do
  desc 'Run all tasks to seed demo'
  task album_and_attachments: :environment do
    puts 'Initializing backup process'
    puts "🏛️ 1st step get albums and galleries and merge them and update ids"
    puts Rake::Task['csv:merge_albums'].invoke
    puts "🏛️ 2nd step from updated albums import blobs and attachments"
    puts Rake::Task['backup:albums'].invoke
    puts Rake::Task['backup:active_storage_blobs'].invoke
    # puts Rake::Task['csv:update_attachments'].invoke
    puts "🏛️ 3rd step from imported attachments update ids"
    puts Rake::Task['backup:active_storage_attachments'].invoke
    puts "🏛️ 4th step for assign to undefined album the orphan attachments"
    puts Rake::Task['backup:undefined_orphan_attachments'].invoke
  end
end
