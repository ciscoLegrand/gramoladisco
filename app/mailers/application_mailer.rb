class ApplicationMailer < ActionMailer::Base
  default from: "fran@lagramoladisco.com" if Rails.env.staging?
  default from: "cisco.glez@gmail.com" if Rails.env.production? # TODO: cambiar este email.
  layout "mailer"
  prepend_view_path Rails.root.join('app', 'views', 'mailers')
end
