module RequestHandler
  def self.process_request(data)
    # Rails.logger.info "😈 Processing request: #{data.inspect}"
    # Extract relevant information from request data
    parameters = {
      message: data[:message],
      remote_ip: data[:remote_ip],
      user_agent: data[:user_agent],
      controller_name: data[:controller],
      action_name: data[:action],
      url: data[:url],
      # status_code: data[:status_code],
      params: data[:params],
      request_method: data[:request_method],
      referer: data[:referer],
      accept_language: data[:accept_language],
      # origin: data[:origin],
      host: data[:host],
      content_type: data[:content_type],
      content_length: data[:content_length],
      session_id: data[:session_id],
      cookies: data[:cookies],
      user_id: data[:user_id]
    }

    # Check if the request should be blocked
    if blocked_request?(parameters[:url])
      block_ip(parameters[:remote_ip])
      create_spam_request(parameters)
      # Rails.logger.info "🚫 Blocked request from #{parameters[:remote_ip]}"
      return
    end

    # create_spam_request(parameters) if blocked_status_code?(parameters[:status_code])
  end

  private

  def self.blocked_request?(url)
    config = load_blocked_endpoints_config
    patterns = config['patterns'].map { |pattern| Regexp.new(pattern) }
    patterns_match = patterns.any? { |pattern| pattern =~ url }
    keywords_match = config['keywords'].any? { |keyword| url.include?(keyword) }
    patterns_match || keywords_match
  end


  def self.blocked_status_code?(status_code)
    config = load_blocked_endpoints_config
    config['status_codes'].include?(status_code)
  end

  def self.load_blocked_endpoints_config
    YAML.safe_load(File.read(Rails.root.join('config', 'blocked_endpoints.yml')))
  end

  def self.block_ip(remote_ip)
    Rails.cache.write("blocked_#{remote_ip}", true, expires_in: 15.minutes)
    Rails.logger.info("Blocked access from #{remote_ip} for 15 minutes.")
  end

  def self.create_spam_request(parameters)
    SpamRequest.create(parameters)
  end
end
