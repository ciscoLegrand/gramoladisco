class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[show update]

  def index
    add_breadcrumb t('breadcrumbs.user.index')
    items = params[:items]
    sort_column = params[:sort] || 'created_at'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @users = User.order_by(sort_column, sort_direction)
    @users = User.by_role(params[:role]) if params[:role].present?
    @users = User.search(params[:text]) if params[:text].present?
    @headers = %w[name surname email role]

    @roles = User.all.pluck(:role).uniq.reject { |role| role == 'superadmin' }

    @pagy, @users = pagy(@users, items: items)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show; end

  def update
    @user.customer! if params[:role].eql?('customer')
    @user.employee! if params[:role].eql?('employee')
    @user.admin!    if params[:role].eql?('admin')

    respond_to do |format|
      flash.now[:success] = { title: t('.success.title', name: @user.name), body: t('.success.body')}
      format.turbo_stream
    end
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
