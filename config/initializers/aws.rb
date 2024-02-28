require 'aws-sdk-s3'

Aws::S3::Client.new(
  region: Rails.application.credentials.dig(:DO_REGION),
  endpoint: Rails.application.credentials.dig(:DO_ENDPOINT),
  access_key_id: Rails.application.credentials.dig(:DO_ACCESS_KEY_ID),
  secret_access_key: Rails.application.credentials.dig(:DO_SECRET_ACCESS_KEY),
  force_path_style: true
)
