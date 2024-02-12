class PublishAlbumJob < ApplicationJob
  queue_as :default

  def perform(album)
    album.update!(published_at: Time.zone.now, status: 'publish') if album.draft?
    Rails.logger.info "El album #{album.title} está con status: #{album.status} con fecha #{album.published_at.strftime('%d/%m/%Y')}"
    album_name = album.title
    magic_link = Rails.application
                      .routes
                      .url_helpers
                      .verify_password_album_url(album, host: Rails.application.config.action_mailer.default_url_options[:host], password: album.password)

    AlbumMailer.with(album_name: album_name, magic_link: magic_link)
               .publish_notification
               .deliver_later
    Rails.logger.info("🔥🔥Email para #{album_name} enviado🔥🔥")
  rescue StandardError => e
    Rails.logger.info "Ha ocurrido un error en la ejecucion del job #{e.message}"
    raise e
  end
end
