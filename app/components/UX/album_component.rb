# frozen_string_literal: true

class UX::AlbumComponent < ViewComponent::Base
  with_collection_parameter :album
  
  attr_accessor :album
  def initialize(album:)
    @album = album
  end

  def render?
    Rails.logger.debug "📷📷 AlbumComponent#render? #{album.publish?} 📷📷"
    @album.present? && @album.publish? && @album.images.attached?
  end
end