class Contact < ApplicationRecord
  has_rich_text :subject

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  validates :subject, length: { minimum: 10, maximum: 500 }
end
