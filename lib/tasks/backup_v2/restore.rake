namespace :restore do
  desc 'Import albums from a CSV file'
  task albums: :environment do
    csv_albums_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')
    abort "🚫 El archivo #{csv_albums_path} no existe!" unless File.exist?(csv_albums_path)
    csv_attachments_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_attachments.csv')
    abort "🚫 El archivo #{csv_attachments_path} no existe!" unless File.exist?(csv_attachments_path)
    csv_blobs_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_blobs.csv')
    abort "🚫 El archivo #{csv_blobs_path} no existe!" unless File.exist?(csv_blobs_path)

    blob_id_to_uuid = {}
    aux = 0
    total_rows = CSV.read(csv_blobs_path, headers: true).size
    CSV.foreach(csv_blobs_path, headers: true, header_converters: :symbol) do |row|
      metadata = if row[:metadata] != 'NULL' && !row[:metadata].nil? && !row[:metadata].empty?
                   JSON.parse(row[:metadata]) rescue {}
                 else
                   {}
                 end

      new_blob = ActiveStorage::Blob.create!(
        filename: row[:filename],
        content_type: row[:content_type],
        metadata: metadata,
        byte_size: row[:byte_size],
        checksum: row[:checksum],
        service_name: 'spaces',
      )

      blob_id_to_uuid[row[:id].to_i] = new_blob.id
      aux += 1
      puts "🕥 [#{aux}/#{total_rows}] Blob creado: #{new_blob.filename}"
    end

    AlbumTemp = Struct.new(:id, :title, :date_event, :password, :emails, :created_at, :updated_at, :status, :gallery_ids, :images, keyword_init: true) do
      def initialize(*args)
        super
        self.images ||= []
      end

      def attach_image(blob)
        images << blob
      end
    end

    error_records = []
    total_rows = CSV.read(csv_albums_path, headers: true).size
    current_row = 0

    CSV.foreach(csv_albums_path, headers: true, header_converters: :symbol) do |album_row|
      current_row += 1
      puts "🕥 [#{current_row}/#{total_rows}] procesando album #{album_row[:title]}..."

      temp_album = AlbumTemp.new(
        id: album_row[:id],
        title: album_row[:title],
        date_event: Date.parse(album_row[:date_event]),
        password: album_row[:password],
        emails: {},
        created_at: DateTime.parse(album_row[:created_at]),
        updated_at: DateTime.parse(album_row[:updated_at]),
        status: 'draft',
        gallery_ids: album_row[:galleries].split(',')
      )

      attachments = CSV.read(csv_attachments_path, headers: true, header_converters: :symbol)
      matching_attachments = attachments.select { |a| temp_album.gallery_ids.include?(a[:record_id]) && a[:record_type] == 'Gallery' }
      total_images = matching_attachments.count
      puts "🕥 [#{current_row}/#{total_rows}] Procesando #{total_images} imágenes..."

      matching_attachments.each_with_index do |attachment, index|
        new_blob_uuid = blob_id_to_uuid[attachment[:blob_id].to_i]
        blob = ActiveStorage::Blob.find_by(id: new_blob_uuid)

        if blob
          temp_album.attach_image(blob)
          puts "[#{index + 1}/#{total_images}] Imagen asociada al álbum #{temp_album.title}"
        else
          puts "❌ No se encontró el blob para el ID #{new_blob_uuid}"
        end
      end

      if temp_album.images.empty?
        error_message = "Ninguna imagen añadida al álbum #{temp_album.title}"
        puts "⚠️ #{error_message}"
        error_records << {
          id: temp_album.id,
          title: temp_album.title,
          total_images_processed: total_images,
          total_images_added: temp_album.images.count,
          error: error_message
        }
      end

      final_album = Album.create!(
        title: temp_album.title,
        date_event: temp_album.date_event,
        password: temp_album.password,
        emails: temp_album.emails,
        created_at: temp_album.created_at,
        updated_at: temp_album.updated_at,
        status: temp_album.status
      )

      temp_album.images.each do |image|
        final_album.images.attach(image)
      end

      puts "✅ Álbum [#{current_row}/#{total_rows}] creado exitosamente con #{temp_album.images.count} imágenes."
      puts "🕥 Esperando 30 segundos para el siguiente álbum..."
      30.times do |i|
        sleep(1)
        putc '.'
      end
    end

    generate_error_report(error_records) unless error_records.empty?
  end
end

def generate_error_report(error_records)
  headers = %w[ID Title Processed Added Error]
  attributes = [:id, :title, :total_images_processed, :total_images_added, :error]

  file_details = ExcelService::Generator.new(
    collection: error_records,
    headers: headers,
    attributes: attributes,
    options: {
      styles: { header: { bg_color: 'FF0000' } },
      file_name: "ErrorReport_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
    }
  ).call

  puts "🗃️ Reporte de errores generado: #{file_details[:file_path]}"
end
