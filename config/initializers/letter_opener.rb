# config/initializers/letter_opener.rb

LetterOpener.configure do |config|
  # Para sobrescribir la ubicación del almacenamiento de mensajes.
  # El valor por defecto es `tmp/letter_opener`
  config.location = Rails.root.join('tmp', 'lo_emails')

  # Para renderizar solo el cuerpo del mensaje, sin metadatos adicionales, contenedores o estilos.
  # El valor por defecto es `:default` que renderiza el mensaje estilizado mostrando metadatos útiles.
  config.message_template = :light

  # Para cambiar el esquema URI del archivo predeterminado, puedes proporcionar la configuración `file_uri_scheme`.
  # Puede ser útil cuando usas WSL (Windows Subsystem for Linux) y el esquema predeterminado no funciona para ti.
  # El valor por defecto es en blanco
  config.file_uri_scheme = "file://wsl%24/Ubuntu-22.04"
end
