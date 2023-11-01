if Rails.env.development?
  $redis = Redis.new(:host => "localhost", :port => 6379)
else
  $redis = Redis.new(:url => Figaro.env.rediscloud_url)
end
