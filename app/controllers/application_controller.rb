class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Logging
  add_flash_types :success, :error, :alert, :notice
end
