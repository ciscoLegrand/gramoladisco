class Admin::DashboardController < Admin::BaseController
  def index
    add_breadcrumb 'Dashboard'
    @unread = Contact.unread.count
  end

  private

end
