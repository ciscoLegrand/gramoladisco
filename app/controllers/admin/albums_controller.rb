class Admin::AlbumsController < ApplicationController
  layout "admin"
  before_action :set_album, only: %i[ show edit update destroy publish]

  # GET /admin/albums or /admin/albums.json
  def index
    @albums = Album.all.order(date_event: :desc)
    @years  = @albums.pluck(:date_event).map(&:year).uniq.sort.reverse
    @albums = Album.draft                   if params[:draft].present?
    @albums = Album.published               if params[:published].present?
    @albums = Album.by_year(params[:year])  if params[:year].present?
      
    @total_records = @albums.count
    @pagy, @albums = pagy(@albums, items: 5)

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @albums }
    end
  end

  # GET /admin/albums/1 or /admin/albums/1.json
  def show
  end

  # GET /admin/albums/new
  def new
    @album = Album.new
  end

  # GET /admin/albums/1/edit
  def edit
  end

  # POST /admin/albums or /admin/albums.json
  def create
    @album = Album.new(album_params)
    @album.current_host    = request.host
    @album.current_user_id = current_user&.id
    respond_to do |format|
      if @album.save
        format.html { redirect_to edit_admin_album_url(@album), success: { title: t('admin.albums.create.success.title'), body: t('admin.albums.create.success.body') } }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { redirect_to new_admin_album_url, alert: { title: t('admin.albums.create.success.title'), body: @album.errors.full_messages } }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/albums/1 or /admin/albums/1.json
  def update
    @album.current_host     = request.host
    @album.current_user_id  = current_user&.id
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to admin_albums_path, success: { title: t('admin.albums.update.success.title', name: @album.title), body: t('admin.albums.update.success.body') } }
        format.turbo_stream do
          flash.now[:success] = { title: t('admin.albums.update.success.title', name: @album.title), body:t('admin.albums.update.success.body') }
          render 'admin/albums/turbo_streams/update'
        end
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/albums/1 or /admin/albums/1.json
  def destroy
    name = @album.title
    PurgeImagesJob.perform_later(@album)
  
    respond_to do |format|
      format.html { redirect_to admin_albums_url, success: {title: t('admin.albums.destroy.success.title', name: name), body: t('admin.albums.destroy.success.body') } }
      format.turbo_stream do
        flash.now[:success] = { title: t('admin.albums.destroy.success.title', name: name), body: t('admin.albums.destroy.success.body') }
        render 'admin/albums/turbo_streams/destroy'
      end
      format.json { head :no_content }
    end
  end

  def publish
    respond_to do |format|
      if @album.images.attached?
        @album.publish!
        PublishAlbumJob.perform_later(@album)
        format.html { redirect_to admin_album_url(@album), success: { title: t('admin.albums.publish.success.title', name: @album.title), body: t('admin.albums.publish.success.body') } }
        format.turbo_stream do
          flash.now[:success] = { title: t('admin.albums.publish.success.title', name: @album.title), body: t('admin.albums.publish.success.body')}
          render 'admin/albums/turbo_streams/publish'
        end
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { redirect_to admin_albums_path, alert: { title: t('admin.albums.publish.alert.title', name: @album.title), body: t('admin.albums.publish.alert.body') } }
        format.turbo_stream do
          flash.now[:alert] = { title: t('admin.albums.publish.alert.title', name: @album.title), body: t('admin.albums.publish.alert.body') } 
          render 'admin/albums/turbo_streams/publish'
        end
        format.json { render :show, status: :unprocessable_entity, location: @album }
      end
    end
  end

  # POST /admin/albums/search
  def search
    @albums = Album.all
    text_fragment = params[:title]
    @filtered_albums = @albums.select { |e| e.title.upcase.include?(text_fragment.upcase) }
    respond_to do |format|
      format.turbo_stream do
        render 'admin/albums/turbo_streams/search_results'
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def album_params
      params.require(:album).permit(:title, :password, :code, :counter, :emails, :date_event, :published_at, :status, images: [])
    end
end
