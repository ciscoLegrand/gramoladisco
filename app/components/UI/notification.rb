# frozen_string_literal: true

class UI::Notification < ViewComponent::Base
  attr_reader :data, :type

  def initialize(type:, data:)
    @data = prepare_data(data)
    @data[:timeout] ||= 50000
    @type = type
  end

  def prepare_data(data)
    case data
    when Hash
      data.with_indifferent_access
    else
      { body: data }.with_indifferent_access
    end
  end


  def icon
    case type
    when "success"
      "circle-check"
    when "alert"
      "alert-triangle"
    when "error"
      "alert-triangle"
    when "notice"
      "info-square-rounded"
    end
  end

  def color
    case type
    when "success"
      "green-500"
    when "error"
      "red-500"
    when "alert"
      "orange-500"
    when "notice"
      "blue-500"
    end
  end

  def bg_color
    case type
    when "success"
      "green-100"
    when "error"
      "red-100"
    when "alert"
      "orange-100"
    when "notice"
      "blue-100"
    end
  end

  def dark_bg_color
    case type
    when "success"
      "green-800"
    when "error"
      "red-800"
    when "alert"
      "orange-700"
    when "notice"
      "blue-800"
    end
  end

  def dark_text_color
    case type
    when "success"
      "green-200"
    when "error"
      "red-200"
    when "alert"
      "orange-200"
    when "notice"
      "blue-200"
    end
  end
end
