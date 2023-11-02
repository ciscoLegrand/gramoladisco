class PublishAlbumJob < ApplicationJob
  queue_as :default

  def perform(album)
    return Rails.logger.info('🔥🔥Album ya publicado') if album.publish?
    return Rails.logger.info("🔥🔥Se tiene que publicar el #{album.publised_at}") if (album.published_at >= Time.zone.now)
    
    album.publish!
    Rails.logger.info "🔥🔥Album: #{album.title} publicado🔥🔥"
    album_name = album.title
    magic_link = Rails.application
                      .routes
                      .url_helpers
                      .verify_password_album_url(album, host: Figaro.env.base_url, password: album.password)

    AlbumMailer.with(album_name: album_name, magic_link: magic_link)
               .publish_notification
               .deliver_later
    Rails.logger.info("🔥🔥Email para #{album_name} enviado🔥🔥")
  end
end

