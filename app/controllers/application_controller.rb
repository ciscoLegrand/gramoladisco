class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Logging
  add_flash_types :success, :error, :alert, :notice

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname, :phone_number, :role, :email, :password, :password_confirmation])
  end
end
