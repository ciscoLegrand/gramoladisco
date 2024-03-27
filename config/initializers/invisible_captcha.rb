InvisibleCaptcha.setup do |config|
  config.visual_honeypots = false
  config.timestamp_threshold = 2
  config.timestamp_enabled = true
  config.injectable_styles = false
  config.spinner_enabled = true
end

ActiveSupport::Notifications.subscribe('invisible_captcha.spam_detected') do |*args, data|
  SpamRequest.create(
    message: data[:message],
    remote_ip: data[:remote_ip],
    user_agent: data[:user_agent],
    controller_name: data[:controller],
    action_name: data[:action],
    url: data[:url],
    status_code: data[:status_code],
    params: data[:params],
    request_method: data[:request_method],
    referer: data[:referer],
    accept_language: data[:accept_language],
    origin: data[:origin],
    host: data[:host],
    content_type: data[:content_type],
    content_length: data[:content_length],
    session_id: data[:session_id],
    cookies: data[:cookies],
    user_id: data[:user_id]
  )
end
