class PublishAlbumJob < ApplicationJob
  queue_as :default

  def perform(album)
    return Rails.logger.info('🔥🔥Album ya publicado') if album.publish?
    Rails.logger.info "🔥🔥Album: #{album.title} publicado🔥🔥"
    album_name = album.title
    magic_link = Rails.application
                      .routes
                      .url_helpers
                      .verify_password_album_url(album, host: Rails.application.config.action_mailer.default_url_options[:host], password: album.password)

    AlbumMailer.with(album_name: album_name, magic_link: magic_link)
               .publish_notification
               .deliver_later
    Rails.logger.info("🔥🔥Email para #{album_name} enviado🔥🔥")
  end
end
