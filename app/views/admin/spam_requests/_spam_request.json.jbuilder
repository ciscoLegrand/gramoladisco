json.extract! spam_request, :id, :created_at, :updated_at
json.url spam_request_path(spam_request, format: :json)
