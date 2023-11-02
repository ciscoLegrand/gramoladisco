class ApplicationMailer < ActionMailer::Base
  default from: "fran@lagramoladisco.com"
  layout "mailer"
  prepend_view_path "app/views/mailers"
end
