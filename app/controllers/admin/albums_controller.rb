class Admin::AlbumsController < Admin::BaseController
  before_action :set_album, only: %i[ show edit update destroy publish]

  # GET /admin/albums or /admin/albums.json
  def index
    add_breadcrumb 'Albums'
    items = params[:items]
    sort_column = params[:sort] || 'created_at'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @albums = Album.order_by(sort_column, sort_direction)
    @albums = Album.ordered_by_image_count(sort_direction) if sort_column.eql?('images')

    @years  = @albums.pluck(:date_event).map(&:year).uniq.sort.reverse
    @albums = Album.draft                   if params[:draft].present?
    @albums = Album.published               if params[:published].present?
    @albums = Album.by_year(params[:year])  if params[:year].present?


    @headers = %w[title images password published_at date_event]

    @total_records = @albums.count
    @pagy, @albums = pagy(@albums)
  end

  # GET /admin/albums/1 or /admin/albums/1.json
  def show
    add_breadcrumb t('breadcrumbs.album.index'), admin_albums_path(items: params[:items].presence || 10)
    add_breadcrumb @album.title
    @headers = %w[title images password published_at date_event]
  end

  # GET /admin/albums/new
  def new
    add_breadcrumb t('breadcrumbs.album.index'), admin_albums_path(items: params[:items].presence || 10)
    add_breadcrumb t('breadcrumbs.album.new')
    @album = Album.new
  end

  # GET /admin/albums/1/edit
  def edit
    add_breadcrumb t('breadcrumbs.album.index'), admin_albums_path(items: params[:items].presence || 10)
    add_breadcrumb t('breadcrumbs.album.edit', name: @album.title)
  end

  # POST /admin/albums or /admin/albums.json
  def create
    @album = Album.new(album_params)
    @album.current_host    = request.host
    @album.current_user_id = current_user&.id
    respond_to do |format|
      if @album.save
        flash.now[:success] = { title: t('.success.title'), body: t('.success.body')}
        format.turbo_stream
        format.html { redirect_to admin_albums_path(items: params[:items].presence || 10) }
      else
        flash.now[:error] = { title: t('.error.title'), body: t('.error.body', errors: @album.errors.full_messages.presence || '')}
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/albums/1 or /admin/albums/1.json
  def update
    @album.current_host     = request.host
    @album.current_user_id  = current_user&.id
    respond_to do |format|
      if @album.update(album_params)
        flash.now[:success] = { title: t('.success.title'), body: t('.success.body')}
      else
        flash.now[:error] = { title: t('.error.title'), body: t('.error.body', errors: @album.errors.full_messages.presence || '')}
      end
      format.turbo_stream
    end
  end

  # DELETE /admin/albums/1 or /admin/albums/1.json
  def destroy
    name = @album.title
    # PurgeImagesJob.perform_later(@album)

    respond_to do |format|
      if @album.destroy
        flash.now[:success] = { title: t('.success.title', name: name), body: t('.success.body')}
      else
        flash.now[:error] = { title: t('.alert.title', name: name), body: t('.alert.body', errors: @album.errors.full_messages.presence || '')}
      end
      format.turbo_stream
      format.html { redirect_to admin_albums_path(items: params[:items].presence || 10) }
    end
  end

  # POST /admin/albums/1/publish
  def publish
    respond_to do |format|
      if @album.images.attached?
        @album.update!(published_at: Time.zone.now, status: 'publish')
        PublishAlbumJob.perform_later(@album)
        flash.now[:success] = { title: t('.success.title', name: @album.title), body: t('.success.body')}
      else
        flash.now[:alert] = { title: t('.alert.title', name: @album.title), body: t('.alert.body', errors: @album.errors.full_messages.presence || '') }
      end
      format.turbo_stream
      format.html { redirect_to admin_albums_path(items: params[:items].presence || 10) }
    end
  end

  # POST /admin/albums/search
  def search
    @albums = Album.all
    text_fragment = params[:title].to_s
    @filtered_albums = @albums.select { |e| e.title.upcase.include?(text_fragment.upcase) }
    respond_to do |format|
      format.turbo_stream
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
