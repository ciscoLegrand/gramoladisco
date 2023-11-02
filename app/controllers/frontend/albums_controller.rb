class Frontend::AlbumsController < ApplicationController
  before_action :set_album, only: %i[ show verify_password]

  # GET /albums or /albums.json
  def index
    @pagy, @albums = pagy_countless(Album.published, items: 12)
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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            :modal,
            partial: "frontend/albums/images/album",
            locals: { album: @album }
          )
        end
      end
    else
      flash.now[:error] = { title: "Alert", body: "Wrong password, please try again." }

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(:modal, partial: "frontend/albums/images/verify_password", locals: { album: @album }),
            turbo_stream.prepend(:notification, partial: "layouts/shared/notification")
          ]
        end
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.friendly.find(params[:id])
  end
end
