class Admin::ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_s3_client, only: [:create]

  BUCKET_NAME = Rails.application.credentials.dig(:digital_ocean, :bucket)

  def create
    Rails.logger.info BUCKET_NAME
    @album = Album.find(params[:album_id])
    if params[:images]
      images = params[:images].values

      images.each do |image|
        key = "#{@album.slug}/#{image.original_filename}"

        # Sube la imagen directamente a DigitalOcean Spaces
        @s3_client.put_object(
          bucket: BUCKET_NAME,
          key: key,
          body: image,
          acl: 'public-read'
        )

        # Crea un blob en ActiveStorage que referencia la imagen en Spaces
        blob = ActiveStorage::Blob.create!(
          key: key,
          filename: image.original_filename,
          content_type: image.content_type,
          byte_size: image.size,
          checksum: Digest::MD5.base64digest(image.read),
          service_name: 'spaces' # Asegúrate de que este sea el nombre de tu servicio configurado para Active Storage
        )

        @album.images.attach(blob) # Asocia el blob con el álbum
      end

      if @album.images.attached?
        image_ids = @album.images.last(images.size).map(&:id)
        render json: { message: 'success', file_ids: image_ids }, status: :created
      else
        render json: { error: 'Failed to attach images' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'No file uploaded' }, status: :unprocessable_entity
    end
  end

  def delete_all
    Rails.logger.info("Album ID: #{params[:album_id]}")
    @album = Album.find(params[:album_id])
    @album.images.purge
    render json: { message: 'All images successfully deleted' }, status: :ok
  end

  private

  def set_s3_client
    @s3_client = Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:digital_ocean, :region),
      endpoint: Rails.application.credentials.dig(:digital_ocean, :endpoint),
      access_key_id: Rails.application.credentials.dig(:digital_ocean, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:digital_ocean, :secret_access_key),
      force_path_style: true
    )
  end
end
