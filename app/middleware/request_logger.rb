class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    response = @app.call(env)[1]

    user_id = defined?(current_user) && current_user.present? ? current_user.id : nil

    data = {
      message: nil,
      remote_ip: request.ip,
      user_agent: request.user_agent,
      controller: env['action_controller.instance']&.controller_name,
      action: env['action_controller.instance']&.action_name,
      url: request.url,
      # status_code: response&.status,
      params: request.params,
      request_method: request.request_method,
      referer: request.referer,
      accept_language: request.accept_language,
      # origin: request&.origin || nil,
      host: request.host,
      content_type: request.content_type,
      content_length: request.content_length,
      session_id: request.session.id,
      cookies: request.cookies,
      user_id: user_id
    }

    # Llama a RequestHandler.process_request con los datos recopilados
    RequestHandler.process_request(data.compact)

    # Retorna la respuesta para que continúe la cadena de middleware
    @app.call(env)
  end
end
