class Admin::DashboardController < Admin::BaseController
  def index
    @unread = Contact.unread.count
  end

  private

end
