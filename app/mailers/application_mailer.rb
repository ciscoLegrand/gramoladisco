class ApplicationMailer < ActionMailer::Base
  default from: "fran@lagramoladisco.com"
  layout "mailer"
  prepend_view_path Rails.root.join('app', 'views', 'mailers')
end
