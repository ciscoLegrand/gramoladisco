# frozen_string_literal: true

class UI::UserCard < ViewComponent::Base
  attr_reader :user, :options

  def initialize(user:, options: {})
    super
    @user = user.nil? ? guest : user
    @options = options
  end

  def guest
    OpenStruct.new(
      name: 'Gramolo',
      email: 'guest@gramola.com'
    )
  end

  def scope_color
    color = 'border-gray-200 text-gray-900'
    color
  end

  def container_style
    options[:container]
  end

  def button_style
    options[:button]
  end

  def avatar_style
    options[:avatar]
  end

  def dropdown
    {
      style: options.dig(:dropdown, :style),
      position: options.dig(:dropdown, :position),
    }
  end
end
