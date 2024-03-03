require 'csv'
namespace :backup do
  desc "Import albums from recovered_albums.csv"
  task albums: :environment do
    csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')
    error_records= []

    Album.destroy_all
    puts 'All Albums destroyed'
    ActiveStorage::Blob.destroy_all
    puts 'All Blobs destroyed'
    ActiveStorage::Attachment.destroy_all
    puts 'All Attachments destroyed'

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
        album.save!
        puts "💾 Album #{id} created with title #{title} is valid #{album.valid? ? '✅' : '❌' } and saved #{album.persisted? ? '✅' : '❌' }"
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
    rescue StandardError => e
      puts "❌ Error creating album with id #{id} and title #{title} -> #{e.message} #{e.backtrace}"
      puts "❌ Album #{id} created with title #{title}"
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

        # Asegurarse de que metadata no sea 'NULL' antes de intentar analizarlo
        if attributes['metadata'].present? && attributes['metadata'] != 'NULL'
          begin
            attributes['metadata'] = JSON.parse(attributes['metadata'])
          rescue JSON::ParserError
            attributes['metadata'] = {}
            puts "Advertencia: El valor de 'metadata' para la fila con id #{attributes['id']} no es un JSON válido."
          end
        else
          attributes['metadata'] = {}
        end

        unless ActiveStorage::Blob.exists?(id: attributes['id'], key: attributes['key'])
          blob = ActiveStorage::Blob.new(attributes)

          if blob.save
            puts "✅ Blob #{blob.id} creado exitosamente."
          else
            puts "❌ Error creando blob: #{blob.errors.full_messages.join(', ')}"
            error_records << { id: attributes['id'], title: attributes['filename'], error: blob.errors.full_messages.join(', ') }
          end
        else
          puts "❌ El blob con ID #{attributes['id']} ya existe."
          error_records << { id: attributes['id'], title: attributes['filename'], key: attributes['key'], error: "El blob #{attributes['key']} ya existe." }
        end
      rescue StandardError => e
        puts "❌ Error procesando fila #{row.inspect}: #{e.message}"
        error_records << { id: row['id'], title: row['filename'], error: e.message }
      end
    end
    generate_error_report(error_records) unless error_records.empty?
  end

  desc 'Reassign Active Storage Attachments from galleries to albums'
  task active_storage_attachments: :environment do
    attachments_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_attachments.csv')
    albums_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'recovered_albums.csv')
    error_records = []
    gallery_attachments = {}

    # Verificar si el archivo de attachments existe
    unless File.exist?(attachments_csv_path)
      puts "El archivo #{attachments_csv_path} no existe!"
      exit
    end

    # Leer gr_attachments.csv y almacenar los attachments de las galerías
    CSV.foreach(attachments_csv_path, headers: true) do |row|
      if row['record_type'] == 'Gallery'
        gallery_id = row['record_id']
        gallery_attachments[gallery_id] ||= []
        gallery_attachments[gallery_id] << row.to_hash
      end
    end

    # Verificar si el archivo de álbumes existe
    unless File.exist?(albums_csv_path)
      puts "El archivo #{albums_csv_path} no existe!"
      exit
    end

    # Leer recovered_albums.csv y reasignar attachments
    CSV.foreach(albums_csv_path, headers: true) do |album_row|
      begin
        album_id = album_row['id']
        gallery_ids = album_row['galleries'].split(',')

        gallery_ids.each do |gallery_id|
          next unless gallery_attachments[gallery_id]

          gallery_attachments[gallery_id].each do |attachment_data|
            # Crear una nueva instancia de ActiveStorage::Attachment
            new_attachment = ActiveStorage::Attachment.new(
              id: attachment_data['id'],
              name: attachment_data['name'],
              record_type: 'Album', # Asumiendo que el modelo para álbumes es 'Album'
              record_id: album_id, # ID del álbum al que se va a asociar el attachment
              blob_id: attachment_data['blob_id'] # ID del blob asociado
            )

            # Intentar guardar el nuevo attachment
            begin
              if new_attachment.save
                puts "🟢 Attachment #{new_attachment.id} reasignado al álbum #{album_id} exitosamente."
              else
                raise ActiveRecord::RecordInvalid.new(new_attachment)
              end
            rescue ActiveRecord::RecordInvalid => e
              puts "❌ Error reasignando attachment: #{e.message}"
              error_records << { id: attachment_data['id'], title: attachment_data['name'], key: attachment_data['blob_id'], error: e.message }
            end
          end
        end
      rescue StandardError => e
        puts "❌ Error procesando fila #{album_row.inspect}: #{e.message}"
        error_records << { id: album_row['id'], title: album_row['title'], error: e.message }
      end
    end

    generate_error_report(error_records) unless error_records.empty?
  end

  desc 'Assign Active Storage Attachments to undefined album if the attachment is not assigned to any album'
  task undefined_orphan_attachments: :environment do
    attachments_csv_path = Rails.root.join('lib', 'tasks', 'backup_v2', 'csv_import', 'gr_attachments.csv')
    error_records = []

    undefined_album = Album.find_or_create_by!(title: '_UNDEFINED_', password: '123undefinedalbum456', emails: [User.first.email], date_event: Date.today, status: 'draft')

    CSV.foreach(attachments_csv_path, headers: true) do |row|
      begin
        attachment = ActiveStorage::Attachment.find_by(id: row['id'])
        if attachment.nil?
          new_attachment = ActiveStorage::Attachment.new(
            id: row['id'],
            name: row['name'],
            record_type: 'Album', # Asumiendo que el modelo para álbumes es 'Album'
            record_id: undefined_album.id, # ID del álbum al que se va a asociar el attachment
            blob_id: row['blob_id'] # ID del blob asociado
          )
          if new_attachment.save
            puts "🟢 Attachment #{new_attachment.id} reasignado al álbum #{undefined_album.title} exitosamente."
          else
            error_records << { id: row['id'], title: row['name'], key: row['blob_id'], error: new_attachment.errors.full_messages.join(', ') }
          end
        else
          # Verificar si el attachment ya está asignado a un álbum
          if attachment.record_type == "Album"
            puts "ℹ️ Attachment #{attachment.id} already assigned to an album."
          else
            # Asignar el attachment al álbum 'undefined'
            attachment.update(record_type: 'Album', record_id: undefined_album.id)
            puts "🟢 Attachment #{attachment.id} assigned to 'undefined' album successfully."
          end
        end
      rescue StandardError => e
        puts "❌ Error processing attachment ID #{row['id']}: #{e.message}"
        error_records << { id: row['id'], title: row['name'], key: 'N/A', error: e.message }
      end
    end

    generate_error_report(error_records) unless error_records.empty?
  end

  def generate_error_report(error_records)
    headers = %w[id title key error]
    attributes = [:id, :title, :key, :error]

    file_details = ExcelService::Generator.new(
      collection: error_records,
      headers: headers.map(&:titleize),
      attributes: attributes,
      options: {
        styles: { header: { bg_color: 'FF0000' } }, # Ejemplo de opciones de estilo
        file_name: "ErrorReport_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
      }
    ).call

    puts "🗃️ Reporte de errores generado: #{file_details[:file_path]}"
  end
end
