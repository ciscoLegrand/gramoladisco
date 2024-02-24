class Frontend::PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end
  def privacy; end
end
