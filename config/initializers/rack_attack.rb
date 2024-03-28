BLOCKED_ENDPOINTS = YAML.safe_load(File.read(Rails.root.join('config', 'blocked_endpoints.yml')))

Rack::Attack.blocklist('block malicious requests') do |req|
  # Check if the request URL matches any patterns or contains any keywords
  blocked = BLOCKED_ENDPOINTS['patterns'].any? { |pattern| req.path =~ Regexp.new(pattern) } ||
            BLOCKED_ENDPOINTS['keywords'].any? { |keyword| req.path.downcase.include?(keyword.downcase) }

  if blocked
    ip = req.ip

    parameters = {
      message: "Se ha bloqueado la IP #{ip} mediante Rack Attack",
      remote_ip: req.ip,
      user_agent: req.user_agent,
      controller_name: nil,
      action_name: nil,
      url: req.path,
      # status_code: data[:status_code],
      params: req.params,
      request_method: req.request_method,
      referer: req.referer,
      # accept_language: req.headers['Accept-Language'],
      origin: req.ip,
      host: req.host,
      content_type: req.content_type,
      content_length: req.content_length,
      session_id: nil,
      cookies: req.cookies,
      user_id: nil
    }

    block_ip(parameters[:remote_ip])
    create_spam_request(parameters)
  end

  blocked
end

def block_ip(remote_ip)
  Rails.cache.write("blocked_#{remote_ip}", true, expires_in: 15.minutes)
  Rails.logger.info("Blocked access from #{remote_ip} for 15 minutes.")
end

def create_spam_request(parameters)
  SpamRequest.create(parameters)
end
