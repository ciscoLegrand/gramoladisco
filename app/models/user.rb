class User < ApplicationRecord
  has_one_attached :avatar
  has_one :oauth_access_token, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
        :recoverable, :rememberable,
        :omniauthable, omniauth_providers: [:google_oauth2]

  # enum fields
  enum role: {
    user: "USER",
    customer: "CUSTOMER",
    worker: "WORKER",
    manager: "MANAGER",
    admin: "ADMIN",
    superadmin: "SUPERADMIN"
  }

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

  def self.from_omniauth(access_token)
    user = User.find_by(email: access_token.info.email)
    user ||= User.create!(
      name: access_token.info.first_name,
      surname: access_token.info.last_name,
      email: access_token.info.email,
      password: Devise.friendly_token[0,20],
    )

    user.google_access_token(access_token) if access_token.provider.eql?('google_oauth2')
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

  private

  def generate_access_token
    loop do
      token = SecureRandom.hex
      break token unless User.where(access_token: token).exists?
    end
  end

  def gramola_access_token
    oauth_access_token.destroy if oauth_access_token
    max_uid = User.maximum(:uid)
    oauth_access_token.new(
      provider: 'lagramoladisco',
      uid: (max_uid ? max_uid + 1 : 1).to_s.rjust(10, '0'),
      access_token: generate_access_token,
      refresh_token: generate_access_token,
      scopes: "",
      avatar_url: "",
      expires_at: 15.days.from_now
    )
  end
end
