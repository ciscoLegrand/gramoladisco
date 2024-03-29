class Frontend::AlbumsController < ApplicationController
  before_action :set_album, only: %i[show verify_password download_image]

  # GET /albums or /albums.json
  def index
    albums = Album.search(params[:text]) if params[:text].present?
    albums = Album.published unless params[:text].present?
    @pagy, @albums = pagy_countless(albums, items: 12)
    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
    end
  end

  # GET /albums/1 or /albums/1.json
  def show
    @images = @album.images
    @pagy, @images = pagy_countless(@images, items: 4)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /albums/1/verify_password
  def verify_password
    session[:album_password] = params[:password]

    if @album.password.eql?(session[:album_password])
      @images = @album.images
      @pagy, @images = pagy_countless(@images, items: 4)
      redirect_to album_path(@album)
    else
      redirect_to albums_path, error: { title: "Alert", body: "Wrong password, please try again." }
    end
  end

  def download_image
    blob = ActiveStorage::Blob.find_by(id: params[:image_id])
    if blob
      redirect_to rails_blob_url(blob, disposition: "attachment")
    else
      flash[:alert] = "Imagen no encontrada"
      redirect_to album_path(@album)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.friendly.find(params[:id])
  end
end
