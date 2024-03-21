class Admin::AlbumsController < Admin::BaseController
  before_action :set_album, only: %i[ show edit update destroy publish]
  before_action :set_s3_client, only: [:create]

  # GET /admin/albums or /admin/albums.json
  def index
    add_breadcrumb 'Albums'
    items = params[:items]
    sort_column = params[:sort] || 'created_at'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'

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

    respond_to do |format|
      format.html
      format.json
    end
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
        # Simular la creación de un directorio en DigitalOcean Spaces
        create_album_directory_in_spaces(@album.slug)

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
        flash.now[:success] = { title: t('.success.title', name: @album.title), body: t('.success.body')}
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
      if @album.images.attached? && @album.draft?
        @album.update!  published_at: Time.zone.now,
                        status: 'publish',
                        current_host: request.host,
                        current_user_id: current_user&.id

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
    if params[:text].present?
      @albums = Album.search(params[:text])
    else
      items = params[:items]
      sort_column = params[:sort] || 'created_at'
      sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      @albums = Album.order_by(sort_column, sort_direction)
      @albums = Album.ordered_by_image_count(sort_direction) if sort_column.eql?('images')

      @years  = @albums.pluck(:date_event).map(&:year).uniq.sort.reverse
      @albums = Album.draft                   if params[:draft].present?
      @albums = Album.published               if params[:published].present?
      @albums = Album.by_year(params[:year])  if params[:year].present?
    end
    @pagy, @albums = pagy(@albums)
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

    def set_s3_client
      @s3_client = Aws::S3::Client.new(
        region: Rails.application.credentials.dig(:digital_ocean, :region),
        endpoint: Rails.application.credentials.dig(:digital_ocean, :endpoint),
        access_key_id: Rails.application.credentials.dig(:digital_ocean, :access_key_id),
        secret_access_key: Rails.application.credentials.dig(:digital_ocean, :secret_access_key),
        force_path_style: true
      )
    end

    def create_album_directory_in_spaces(album_slug)
      @s3_client.put_object(bucket: Rails.application.credentials.dig(:digital_ocean, :bucket), key: "#{album_slug}/", body: "")
    end
end
