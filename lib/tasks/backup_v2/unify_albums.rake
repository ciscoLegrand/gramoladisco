require 'csv'

namespace :csv do
  desc "Merge albums and galleries CSV files"
  task merge_albums: :environment do
    albums_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_albums.csv')
    galleries_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_galleries.csv')
    merged_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')

    albums_data = CSV.read(albums_csv_path, headers: true)
    galleries_data = CSV.read(galleries_csv_path, headers: true)

    album_galleries_hash = Hash.new { |hash, key| hash[key] = [] }

    galleries_data.each do |row|
      album_id = row['album_id']
      gallery_id = row['id']
      album_galleries_hash[album_id] << gallery_id
    end

    CSV.open(merged_csv_path, 'wb') do |csv|
      headers = albums_data.headers + ['galleries']
      csv << headers

      albums_data.each do |row|
        album_id = row['id']
        galleries = album_galleries_hash[album_id]
        merged_row = row.fields + [galleries.join(',')]
        csv << merged_row
      end
    end
  end
end
