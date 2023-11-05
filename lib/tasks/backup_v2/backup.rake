require 'csv'
namespace :backup do
  desc "Import albums from recovered_albums.csv"
  task albums: :environment do
    csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')
    error_records= []


    Album.destroy_all
    puts 'Read csv'
    aux = 0
    CSV.foreach(csv_path, headers: true) do |row|
      id = row['id']
      title = row['title']
      date_event = row['date_event']
      password = row['password']
      created_at = row['created_at']
      updated_at = row['updated_at']

      puts "Creating #{aux +=1} album with id #{id} and title #{title}"
      album = Album.new(
        id: id,
        title: title,
        date_event: Date.parse(date_event),
        password: password,
        created_at: DateTime.parse(created_at),
        updated_at: DateTime.parse(updated_at),
        status: 'draft',
        emails: {}
      )
      if album.valid?
        puts "💾 Album #{id} created with title #{title} is valid #{album.valid?} and will be saved"
        album.save!
      else
        album.errors.full_messages.each do |message|
          puts " ⚠️ Error creating album with id #{id} and title #{title} -> #{message}"
          error_records << { id: id, title: title, error: message }
        end
        album.title = "#{title}-#{Date.parse(date_event)}"
        if album.save
          puts "💾 Album #{id} created with title #{album.title}"
        else
          album.errors.full_messages.each do |message|
            puts "⚠️ Error creating album with id #{id} and title #{album.title} -> #{message}"
            error_records << { id: id, title: title, error: message }
          end
        end
      end

      puts "Album #{id} created with title #{title}"
    rescue StandardError => e
      puts "Error creating album with id #{id} and title #{title} -> #{e.message} #{e.backtrace}"
      puts "Album #{id} created with title #{title}"
      error_records << { id: id, title: title, error: e.message }
    end
    generate_error_report(error_records) unless error_records.empty?
  end

  desc 'Import Active Storage Blobs from blobs.csv'
  task active_storage_blobs: :environment do
    csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_blobs.csv')
    error_records = []

    unless File.exist?(csv_path)
      puts "El archivo #{csv_path} no existe!"
      exit
    end

    CSV.foreach(csv_path, headers: true) do |row|
      begin
        attributes = row.to_hash.slice('id', 'key', 'filename', 'content_type', 'metadata', 'byte_size', 'checksum', 'created_at')

        # Verificar si el blob ya existe
        unless ActiveStorage::Blob.exists?(id: attributes['id'])
          blob = ActiveStorage::Blob.new(attributes)

          if blob.save
            puts "Blob #{blob.id} creado exitosamente."
          else
            puts "❌ Error creando blob: #{blob.errors.full_messages.join(', ')}"
            error_records << { id: attributes['id'], title: attributes['filename'], error: blob.errors.full_messages.join(', ') }
          end
        else
          puts "❌ El blob con ID #{attributes['id']} ya existe."
          error_records << { id: attributes['id'], title: attributes['filename'], error: 'El blob ya existe' }
        end

      rescue StandardError => e
        puts "❌ Error procesando fila #{row.inspect}: #{e.message}"
        error_records << { id: row['id'], title: row['filename'], error: e.message }
      end
    end
    generate_error_report(error_records) unless error_records.empty?
  end

  desc 'Import Active Storage Attachments from updated_attachments.csv'
  task active_storage_attachments: :environment do
    csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'updated_attachments.csv')
    error_records= []

    # Verificar si el archivo existe
    unless File.exist?(csv_path)
      puts "El archivo #{csv_path} no existe!"
      exit
    end

    CSV.foreach(csv_path, headers: true) do |row|
      begin
        # Asumiendo que las columnas del CSV coinciden con los nombres de los campos en la base de datos
        attributes = row.to_hash.slice('id', 'name', 'record_type', 'record_id', 'blob_id')

        # Crear el attachment
        attachment = ActiveStorage::Attachment.new(attributes)

        if attachment.save
          puts "Attachment #{attachment.id} creado exitosamente."
        else
          puts "Error creando attachment: #{attachment.errors.full_messages.join(', ')}"
          error_records << { id: attachment.id, title: attachment.name, error: attachment.errors.full_messages.join(', ') }
        end

      rescue StandardError => e
        puts "Error procesando fila #{row.inspect}: #{e.message}"
        error_records << { id: row['id'], title: row['filename'], error: e.message }
      end
    end
    generate_error_report(error_records) unless error_records.empty?
  end

  def generate_error_report(error_records)
    headers = ['ID', 'Title', 'Error']
    attributes = [:id, :title, :error]

    file_details = ExcelService::Generator.new(
      collection: error_records,
      headers: headers,
      attributes: attributes,
      options: {
        styles: { header: { bg_color: 'FF0000' } }, # Ejemplo de opciones de estilo
        file_name: "ErrorReport_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
      }
    ).call

    puts "🗃️ Reporte de errores generado: #{file_details[:file_path]}"
  end
end
