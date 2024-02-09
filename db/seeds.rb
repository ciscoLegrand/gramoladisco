# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "faker"

Faker::Config.locale = 'es'

user = User.create!(name: 'cisco', surname: 'gonzalez', email: 'cisco.glez@gmail.com', phone_number: '+34123456789', password: 'test123', password_confirmation: 'test123', role: 'admin')
user.confirm

# Establece la fecha de inicio hace 15 meses
start_date = 3.months.ago.to_date

# Itera desde la fecha de inicio hasta hoy
(start_date..Date.today).each do |date|
  rand(0..6).times do
    Contact.create!(
      title: Faker::Lorem.sentence(word_count: 4),
      email: Faker::Internet.email,
      subject: Faker::Lorem.paragraph(sentence_count: 5),
      created_at: date,
      updated_at: date
    )
  end
end
