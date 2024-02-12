# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    Rails.logger.info "current_user: #{current_user.inspect}"
    respond_to do |format|
      if current_user.present?
        flash[:success] = "Bienvenido, #{current_user.email}!"
      else
        flash.now[:error] = 'Usuario o contraseña incorrectos'
      end

      format.html { redirect_to root_path }
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('notification', partial: 'layouts/shared/notification') }
    end
  end

  def after_sign_oput_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
