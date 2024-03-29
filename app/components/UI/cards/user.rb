# frozen_string_literal: true

class UI::Cards::User < ViewComponent::Base
  attr_reader :user, :options, :actions

  def initialize(user:, options: {}, actions: [])
    super
    @user = user.nil? ? guest : user
    @options = options
    @actions = actions
  end

  def guest
    OpenStruct.new(
      name: '',
      email: ''
    )
  end

  def scope_color
    color = 'border-gray-200 text-gray-900'
    color
  end

  def container_style
    options.dig(:container, :style)
  end

  def button_style
    options.dig(:button, :style)
  end

  def avatar_style
    options.dig(:avatar, :style)
  end

  def dropdown
    {
      style:    options.dig(:dropdown, :style),
      position: options.dig(:dropdown, :position),
    }
  end
end
