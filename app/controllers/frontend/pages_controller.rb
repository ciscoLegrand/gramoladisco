class Frontend::PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @reviews = Review.order_by('date', 'desc').limit(32)
  end

  def privacy; end
end
