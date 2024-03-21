class Album < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :date_event

  has_many_attached :images do |attachable|
    attachable.variant :mobile, resize_to_limit: [480, 800]
    attachable.variant :tablet, resize_to_limit: [800, 1280]
    attachable.variant :desktop, resize_to_limit: [1280, 1024]
    attachable.variant :widescreen, resize_to_limit: [1920, 1080]
  end

  enum status: { draft: 'draft', publish: 'publish', closed: 'closed' }

  validates :title,
            presence: true,
            length: { minimum: 3, maximum: 255 }
  # validate :validate_image_size

  attr_accessor :current_host, :current_user_id
  # after_commit :update_image_counter, on: [:create, :update]

  def images_uploaded_after(**dates)
    start_date = dates[:start_date]&.beginning_of_day || Time.now.beginning_of_day
    end_date = dates[:end_date]&.end_of_day || Time.now.end_of_day
    images.blobs.joins(:attachments).where('active_storage_attachments.created_at BETWEEN ? AND ?', start_date, end_date).count
  end

  def update_status!
    if published_at.present? && published_at <= Time.now
      published!
    else
      errors.add(:published_at, 'must be in the past')
    end
  end

  scope :published, -> { where(status: :publish).order(published_at: :desc) }
  scope :closed, -> { where(status: :closed).order(date_event: :desc) }
  scope :draft, -> { where(status: :draft).order(date_event: :desc) }
  scope :by_year, ->(year) { where('extract(year from date_event) = ?', year) }
  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }

  # sort by total of attachments
  scope :ordered_by_image_count, -> (order = :desc) {
    left_joins(images_attachments: :blob)
    .group('albums.id')
    .order(Arel.sql("COUNT(active_storage_blobs.id) #{order}"))
  }

  # ! pgsearch busqueda por campos de texto

  pg_search_scope :search, against: %i[title emails slug], using: {
    tsearch: { prefix: true }
  }

  # TODO: Implementar actualzación de estado de album para cerrarlo una vez que la fecha de publicacion haya pasado 1 año
  def archived?
    closed? || date_event < 1.year.ago
  end

  private

  def slug_candidates
    [
      :title,
      [:title, :date_event_for_slug]
    ]
  end

  def update_image_counter
    UpdateImageCounterJob.perform_later(self.id, @current_host, @current_user_id)
  end

  def validate_image_size
    if images.attached?
      images.each do |image|
        if image.blob.byte_size > 15.megabyte
          image.purge
          errors.add(:images, 'size too large. Images should be less than 15MB each')
        end
      end
    end
  end
end
