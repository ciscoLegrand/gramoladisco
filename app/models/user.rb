class User < ApplicationRecord
  include FriendlyId
  friendly_id :name, use: :slugged
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
        :recoverable, :rememberable,
        :omniauthable, omniauth_providers: [:google_oauth2]

  has_one_attached :avatar, dependent: :destroy
  has_one :oauth_access_token, dependent: :destroy

  # enum fields
  enum role: {
    user: "USER",
    customer: "CUSTOMER",
    employee: "EMPLOYEE",
    manager: "MANAGER",
    admin: "ADMIN",
    superadmin: "SUPERADMIN"
  }

  before_create :generate_slug
  after_create :gramola_access_token, if: -> { oauth_access_token.nil? }

  # Validations
  validates :role,
            presence: true,
            inclusion: { in: roles.keys }

  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 70 }

  validates :surname,
            presence: true,
            length: {minimum:3, maximum:150 }

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone_number,
            format: {
              with: /\A\+?[0-9]{8,15}\z/,
              allow_blank: true
            },
            uniqueness: {
              case_sensitive: false,
              allow_blank: true
            }

  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }
  scope :by_role, ->(role) { where(role: role) }
  scope :search, ->(text) { where('name ILIKE ? OR surname ILIKE ? OR email ILIKE ?', "%#{text}%", "%#{text}%", "%#{text}%") }

  def self.from_omniauth(access_token)
    user = User.find_by(email: access_token.info.email)
    user ||= User.create!(
      name: access_token.info.first_name,
      surname: access_token.info.last_name,
      email: access_token.info.email,
      password: Devise.friendly_token[0,20],
    )

    user.google_access_token(access_token) if access_token.provider.eql?('google_oauth2')
    user.attach_avatar_from_omniauth(access_token) if access_token.info.image.present?
    user
  end

  def google_access_token(access_token)
    return unless access_token.provider.eql? 'google_oauth2'

    oauth_access_token.destroy if oauth_access_token
    create_oauth_access_token(
      provider: access_token.provider,
      uid: access_token.uid,
      access_token: access_token.credentials.token,
      refresh_token: access_token.credentials.refresh_token,
      scopes: access_token.credentials.scopes,
      avatar_url: access_token.info.image,
      expires_at: Time.at(access_token.credentials.expires_at),
    )
  end

  def self.log_hash(hash, prefix = "")
    hash.each do |key, value|
      if value.is_a? Hash
        log_hash(value, "#{prefix}#{key}.")
      else
        Rails.logger.info "#{prefix}#{key}: #{value}"
      end
    end
  end

  def attach_avatar_from_omniauth(access_token)
    return unless avatar.attached? == false

    begin
      avatar.attach(
        io: URI.open(access_token.info.image),
        filename: "avatar-#{email.tr('@.', '')}.jpg",
        content_type: 'image/jpg'
      )
    rescue OpenURI::HTTPError => e
      Rails.logger.error "Error al adjuntar avatar desde OmniAuth: #{e} 💀💀💀"
    end
  end

  private

  def generate_access_token
    loop do
      token = SecureRandom.hex
      break token unless OauthAccessToken.where(access_token: token).exists?
    end
  end

  def gramola_access_token
    oauth_access_token.destroy if oauth_access_token

    max_uid = OauthAccessToken.where(provider: :lagramoladisco)
                              .maximum(:uid).to_i

    create_oauth_access_token(
      provider: 'lagramoladisco',
      uid: (max_uid ? max_uid + 1 : 1).to_s.rjust(10, '0'),
      access_token: generate_access_token,
      refresh_token: generate_access_token,
      scopes: "",
      avatar_url: "",
      expires_at: 15.days.from_now
    )
  end

  def generate_slug
    not_unique_primary_slug = User.where(slug: "#{name}").any?
    not_unique_compose_slug = User.where(slug: "#{name}-#{surname}").any?
    self.slug = "#{name}" unless not_unique_primary_slug
    self.slug = "#{name}-#{surname}" if not_unique_primary_slug
    self.slug = "#{name}-#{surname}-#{SecureRandom.uuid}" if not_unique_compose_slug
  end


end
