class Admin::SpamRequestsController < Admin::BaseController

  # GET /spam_requests or /spam_requests.json
  def index
    add_breadcrumb t('breadcrumbs.spam_requests.index'), :admin_spam_requests_path
    @headers = %w[remote_ip action_name controller_name created_at]

    items = params[:items]
    sort_column = params[:sort] || 'remote_ip'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @spam_requests = SpamRequest.order_by(sort_column, sort_direction)
    @pagy, @spam_requests = pagy(@spam_requests, items:)

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @spam_requests }
    end
  end

  def show
    @spam_request = SpamRequest.find(params[:id])
  end

  def destroy
    @spam_request = SpamRequest.find(params[:id])
    @spam_request.destroy

    respond_to do |format|
      format.html { redirect_to admin_spam_requests_path, notice: t('.destroyed') }
      format.turbo_stream { turbo_stream.remove @spam_request }
    end
  end

  private
end
