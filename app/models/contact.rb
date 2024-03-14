class Contact < ApplicationRecord
  has_rich_text :subject

  after_create :send_email

  enum status: { read: 'read', unread: 'unread' }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :title, presence: true, length: { minimum: 10, maximum: 180 }
  validates :subject, presence: true, length: { minimum: 10, maximum: 1000 }

  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }
  scope :filter_by_text, ->(text) { where('title ILIKE ? OR email ILIKE ?', "%#{text}%", "%#{text}%") }

  def icon
    return 'mail-opened' if read?

    created_at < 15.days.ago ? 'mail-exclamation' : 'mail'
  end

  def color
    return 'slate' if read?
    return 'red'   if created_at < 15.days.ago
    return 'amber' if created_at < 7.days.ago
    'blue'
  end

  private

  def send_email
    mailer = ContactMailer.with(contact: self)
    mailer.customer_email.deliver_now
    mailer.admin_email.deliver_now
  end
end
