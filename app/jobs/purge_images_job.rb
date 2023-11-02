class PurgeImagesJob < ApplicationJob
  queue_as :default

  def perform(album)
    album_name = album.title
    images_count = album.images.size
    message = ""

    begin
      album.images.purge
      album.destroy
    rescue => e
      message = "Error purgando imagenes: #{e.message}"
      Rails.logger.info "PurgeImagesJob: #{e.message}"
    ensure
      AlbumMailer.with(album_name: album_name, images_count: images_count, message: message)
                  .purge_notification
                  .deliver_later
    end

  end
end
