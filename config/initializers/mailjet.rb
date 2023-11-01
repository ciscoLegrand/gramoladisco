# initializers/mailjet.rb
Mailjet.configure do |config|
  config.api_key = Figaro.env.mailjet_api_key
  config.secret_key = Figaro.env.mailjet_secret_key
  config.default_from = Figaro.env.maijet_registered_email
end