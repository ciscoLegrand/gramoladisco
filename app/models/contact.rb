class Contact < ApplicationRecord
  has_rich_text :subject

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  validates :subject, length: { minimum: 10, maximum: 500 }

  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }
  scope :filter_by_text, ->(text) { where('title ILIKE ? OR email ILIKE ?', "%#{text}%", "%#{text}%") }
end
