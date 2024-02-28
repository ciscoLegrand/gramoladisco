require 'aws-sdk-s3'

Aws::S3::Client.new(
  region: Rails.application.credentials.dig(:digital_ocean, :region),
  endpoint: Rails.application.credentials.dig(:digital_ocean, :endpoint),
  access_key_id: Rails.application.credentials.dig(:digital_ocean, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:digital_ocean, :secret_access_key),
  force_path_style: true
)
