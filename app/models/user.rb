class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :confirmable,
         :recoverable, :rememberable, :validatable, :lockable

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

  validates :phone_number,
            uniqueness: true,
            format: { with: /\A(\+34|0034|34)?[ -]*(6|7)[ -]*([0-9][ -]*){8}\z/ }
end
