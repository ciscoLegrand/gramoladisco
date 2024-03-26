BLOCKED_ENDPOINTS = %w(/admin /wp-admin /wp-login.php /phpmyadmin /wp-content /xmlrpc.php /api /admin.php /login.php /dashboard /cgi-bin)

InvisibleCaptcha.setup do |config|
  config.visual_honeypots = false
  config.timestamp_threshold = 2
  config.timestamp_enabled = true
  config.injectable_styles = false
  config.spinner_enabled = true
end

ActiveSupport::Notifications.subscribe('invisible_captcha.spam_detected') do |*args, data|

  if BLOCKED_ENDPOINTS.include?(url)
    Rails.cache.write("blocked_#{remote_ip}", true, expires_in: 15.minutes)
    Rails.logger.info("🚫 Blocked access from #{remote_ip} to #{url} for 15 minutes.")
  end

  message = data[:message]
  remote_ip = data[:remote_ip]
  user_agent = data[:user_agent]
  controller_name = data[:controller]
  action_name = data[:action]
  url = data[:url]
  params = data[:params]
  request_method = data[:request_method]
  referer = data[:referer]
  accept_language = data[:accept_language]
  origin = data[:origin]
  host = data[:host]
  content_type = data[:content_type]
  content_length = data[:content_length]
  session_id = data[:session_id]
  cookies = data[:cookies]
  user_id = data[:user_id]

  SpamRequest.create(
    message: message,
    remote_ip: remote_ip,
    user_agent: user_agent,
    controller_name: controller_name,
    action_name: action_name,
    url: url,
    params: params,
    request_method: request_method,
    referer: referer,
    accept_language: accept_language,
    origin: origin,
    host: host,
    content_type: content_type,
    content_length: content_length,
    session_id: session_id,
    cookies: cookies,
    user_id: user_id
  )
end
