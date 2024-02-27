Mailjet.configure do |config|
  config.api_key = Rails.application.credentials.dig(:MAILJET_API_KEY)
  config.secret_key = Rails.application.credentials.dig(:MAILJET_SECRET_KEY)
  config.default_from = Rails.application.credentials.dig(:MAILJET_REGISTERED_EMAIL)
end
