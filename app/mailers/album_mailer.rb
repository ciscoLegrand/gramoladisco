class AlbumMailer < ApplicationMailer
  def purge_notification
    @album_name = params[:album_name]
    @images_count = params[:images_count]
    @message = params[:message]

    mail(to: 'cisco.glez@gmail.com', subject: 'Images purged from album')
  end

  def publish_notification
    @album_name = params[:album_name]
    @images_count = params[:images_count]
    @message = params[:message]

    mail(to: 'cisco.glez@gmail.com', subject: 'Images published from album')
  end
end
