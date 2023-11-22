class Admin::BaseController < ApplicationController
  layout "admin"
  # before_action :authenticate_user!
  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def ensure_admin
    # unless current_user.admin?
    #   redirect_to root_path, alert: t('admin.dashboard.ensure_admin.alert')
    # end
  end
end
