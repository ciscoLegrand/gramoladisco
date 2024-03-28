class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Logging
  add_flash_types :success, :error, :alert, :notice

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_blocked_ip

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname, :phone_number, :role, :email, :password, :password_confirmation])
  end

  def check_blocked_ip
    if Rails.cache.exist?("blocked_#{request.remote_ip}")
      render json: { error: 'Nice try 🐭!! You have been blocked for doing bad stuffs!! If you want to continue, please contact us!' }, status: :forbidden
    end
  end
end
