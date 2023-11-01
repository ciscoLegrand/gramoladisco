require 'csv'

namespace :csv do
  desc "Update record_id in attachments CSV"
  task update_attachments: :environment do
    recovered_albums_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')
    attachments_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'attachments.csv')
    updated_attachments_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'updated_attachments.csv')

    gallery_to_album_hash = {}
    CSV.foreach(recovered_albums_csv_path, headers: true) do |row|
      album_id = row['id']
      galleries = row['galleries'].split(',')
      galleries.each { |gallery_id| gallery_to_album_hash[gallery_id] = album_id }
    end

    CSV.open(updated_attachments_csv_path, 'wb') do |csv|
      headers = %w[id name record_type record_id blob_id]
      csv << headers

      CSV.foreach(attachments_csv_path, headers: true) do |row|
        if row['record_type'] == 'Gallery'
          gallery_id = row['record_id']
          row['record_id'] = gallery_to_album_hash[gallery_id]
          row['record_type'] = 'Album'
        end
        csv << row
      end
    end
  end
end
