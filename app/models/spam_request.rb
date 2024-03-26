class SpamRequest < ApplicationRecord
  validate :validate_params
  validate :validate_cookies

  scope :order_by, ->(column, direction) { order("#{column} #{direction}") }
  scope :filter_by_text, ->(text) { where('remote_ip ILIKE ? OR action_name ILIKE ? OR controller_name ILIKE ?', "%#{text}%", "%#{text}%", "%#{text}") }

  private

  def validate_params
    return unless params.present?

    begin
      JSON.parse(params.to_json)
    rescue JSON::ParserError
      errors.add(:params, "is not a valid JSON")
    end
  end

  def validate_cookies
    return unless cookies.present?

    begin
      JSON.parse(cookies.to_json)
    rescue JSON::ParserError
      errors.add(:cookies, "is not a valid JSON")
    end
  end
end
