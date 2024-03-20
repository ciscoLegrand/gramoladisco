if Rails.env.development?
  $redis = Redis.new(:host => "localhost", :port => 6379)
else
  $redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'))
end
