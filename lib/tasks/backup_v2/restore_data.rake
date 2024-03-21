namespace :restore do
  desc 'Import albums from a CSV file'
  task picmaton: :environment do
    puts "🗑️ Limpiando blobs, attachments y álbumes existentes..."
    ActiveStorage::Blob.delete_all
    ActiveStorage::Attachment.delete_all
    Album.delete_all

    puts "🔌 Estableciendo conexión con DigitalOcean Spaces..."
    s3_client = Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:digital_ocean, :region),
      endpoint: Rails.application.credentials.dig(:digital_ocean, :endpoint),
      access_key_id: Rails.application.credentials.dig(:digital_ocean, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:digital_ocean, :secret_access_key),
      force_path_style: true
    )
    puts "✅ Conectado a DigitalOcean Spaces."

    puts "📁 Creando álbum SUPERADMIN..."
    superadmin_album = Album.create!(
      title: 'SUPERADMIN',
      date_event: Date.today,
      password: 'test123',
      emails: {},
      created_at: DateTime.current,
      updated_at: DateTime.current,
      status: 'draft'
    )
    puts "✅ Álbum SUPERADMIN creado."

    puts "📦 Importando blobs desde CSV..."
    csv_paths = {
      albums: Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv'),
      attachments: Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_attachments.csv'),
      blobs: Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_blobs.csv')
    }

    csv_paths.each do |key, path|
      abort "🚫 El archivo #{path} no existe!" unless File.exist?(path)
    end

    total_blobs = CSV.read(csv_paths[:blobs], headers: true).size
    new_blobs = []
    CSV.foreach(csv_paths[:blobs], headers: true, header_converters: :symbol).with_index(1) do |row, index|
      puts "[#{index}/#{total_blobs}]🔍 Verificando blob #{row[:filename]} en DigitalOcean Spaces..."
      unless blob_exists_in_space?(s3_client, Rails.application.credentials.dig(:digital_ocean, :bucket), row[:key])
        puts "⚠️ Blob #{row[:filename]} no encontrado en Spaces. Omitiendo..."
        next
      end

      metadata =  if row[:metadata] != 'NULL' && !row[:metadata].nil? && !row[:metadata].empty?
                    JSON.parse(row[:metadata]) rescue {}
                  else
                    {}
                  end
      new_blob = {
        key: row[:key],
        filename: row[:filename],
        content_type: row[:content_type],
        metadata: metadata,
        byte_size: row[:byte_size],
        checksum: row[:checksum],
        service_name: 'spaces',
        created_at: DateTime.parse(row[:created_at]),
        old_id: row[:id]
      }
      new_blobs << new_blob
      puts "[#{index}/#{total_blobs}]✅ Blob procesado y añadido a la lista."
    end
    ActiveStorage::Blob.insert_all(new_blobs)
    puts "✅ Todos los blobs han sido importados."

    total_albums = CSV.read(csv_paths[:albums], headers: true).size
    CSV.foreach(csv_paths[:albums], headers: true, header_converters: :symbol).with_index(1) do |album_row, index|
      puts "[#{index}/#{total_albums}]📁 Creando álbum #{album_row[:title]}..."
      album = Album.create!(
        title: album_row[:title],
        date_event: Date.parse(album_row[:date_event]),
        password: album_row[:password] || 'test123',
        emails: {},
        created_at: DateTime.parse(album_row[:created_at]),
        updated_at: DateTime.parse(album_row[:updated_at]),
        status: 'draft'
      )

      attachments = CSV.read(csv_paths[:attachments], headers: true, header_converters: :symbol)
      gallery_ids = album_row[:galleries].split(',')
      matching_attachments = attachments.select { |a| gallery_ids.include?(a[:record_id]) && a[:record_type] == 'Gallery' }
      total_attachments = matching_attachments.size

      if matching_attachments.empty?
        puts "[#{index}/#{total_albums}]🚫 No se encontraron adjuntos para el álbum #{album.title}. Añadiendo a SUPERADMIN..."
        orphan_blob = ActiveStorage::Blob.find_by(old_id: album_row[:id])
        superadmin_album.images.attach(orphan_blob) if orphan_blob
        puts "[#{index}/#{total_albums}]✅ Blob sin álbum asociado añadido al álbum SUPERADMIN."
      else
        matching_attachments.each_with_index do |attachment, attach_index|
          blob = ActiveStorage::Blob.find_by(old_id: attachment[:blob_id])
          if blob
            album.images.attach(blob)
            puts "[#{index}/#{total_albums}][#{attach_index + 1}/#{total_attachments}]✅ Blob asociado al álbum #{album.title}."
          else
            puts "[#{index}/#{total_albums}][#{attach_index + 1}/#{total_attachments}]⚠️ Blob referenciado no encontrado."
          end
        end
      end
    end
    puts "🏁 Proceso de restauración completado."
  end

  def blob_exists_in_space?(client, bucket, key)
    begin
      client.head_object(bucket: bucket, key: key)
      true
    rescue Aws::S3::Errors::NotFound
      false
    end
  end
end
