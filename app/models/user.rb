class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :confirmable,
         :recoverable, :rememberable, :validatable, :lockable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  # enum fields
  enum role: {
    user: "user",
    customer: "customer",
    worker: "worker",
    manager: "manager",
    admin: "admin",
    superadmin: "superadmin"
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

  # validates :phone_number,
  #           uniqueness: true,
  #           format: { with: /\A(\+34|0034|34)?[ -]*(6|7)[ -]*([0-9][ -]*){8}\z/ }

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
           email: data['email'],
           password: Devise.friendly_token[0,20]
        )
    end
    user
  end
end
