class ApplicationController < ActionController::Base
  include Logging
  add_flash_types :success, :error, :alert, :notice
end
