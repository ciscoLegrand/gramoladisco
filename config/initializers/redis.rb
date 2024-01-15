if Rails.env.development?
  $redis = Redis.new(:host => "localhost", :port => 6379)
else
  $redis = Redis.new(:url => Rails.application.credentials.redis_url)
end
