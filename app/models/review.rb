class Review < ApplicationRecord
  validates :name, :date, :overall_rating, :ratings, :description, presence: true
  validates :overall_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :name, uniqueness: { scope: [:date, :title], message: "La combinación de nombre, fecha y título debe ser única" }

  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }
  scope :by_year, ->(year) { where('extract(year from date) = ?', year) }
  scope :filter_by_text, ->(text) { where('title ILIKE ? OR email ILIKE ?', "%#{text}%", "%#{text}%") }

  def self.find_or_create_review(attributes)
    review = Review.find_or_create_by(name: attributes[:name], date: attributes[:date], title: attributes[:title], ratings: attributes[:ratings])
    review.update(attributes) unless review.persisted?
    review
  end
end
