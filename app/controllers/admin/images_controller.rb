class Admin::ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @album = Album.find(params[:album_id])
    if params[:images]
      images = params[:images].values # Extrae los archivos de las imágenes de los parámetros
      if @album.images.attach(images) # Si la operación fue exitosa
        # Accede a las últimas imágenes adjuntas
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
    @album = Album.find(params[:album_id  ])
    @album.images.purge
    render json: { message: 'All images successfully deleted' }, status: :ok
  end
end
