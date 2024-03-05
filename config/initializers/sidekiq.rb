Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL',Rails.application.credentials.redis_url) }
  config.average_scheduled_poll_interval = 15
  # Si tienes un archivo de configuración de Sidekiq específico y deseas cargarlo, descomenta la siguiente línea:
  # config.sidekiq = YAML.load_file(File.join(Rails.root, 'config', 'sidekiq.yml'))
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', Rails.application.credentials.redis_url) }
end
