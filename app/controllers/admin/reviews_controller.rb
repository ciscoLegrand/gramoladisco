class Admin::ReviewsController < Admin::BaseController

  # GET /admin/reviews
  def index
    add_breadcrumb t('breadcrumbs.reviews.index'), :admin_reviews_path
    @headers = %w[name title date ratings]

    items = params[:items]
    sort_column = params[:sort] || 'title'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @reviews = Review.order_by(sort_column, sort_direction)
    @years  = @reviews.pluck(:date).map(&:year).uniq.sort.reverse
    @reviews = Review.by_year(params[:year])  if params[:year].present?
    @pagy, @reviews = pagy(@reviews, items:)

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @reviews }
    end
  end

  # GET /admin/reviews/:id
  def show
    @review = Review.find(params[:id])
  end
end
