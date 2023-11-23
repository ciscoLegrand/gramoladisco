class UI::NavLink < ViewComponent::Base
  def initialize(path:, icon:, title:)
    @path = path
    @icon = icon
    @title = title
  end

  def call
    active_link_to(@path, class: 'nav-link w-full flex justify-center items-center py-2 text-center') do
      safe_join([title_content, icon_content])
    end
  end

  private

  def title_content
    content_tag(:span, @title, class: 'w-full text-lg', data: { 'decrease-target': 'link' })
  end

  def icon_content
    inline_svg_tag(@icon, class: 'w-8 h-8', data: { 'decrease-target': 'iconLeft' })
  end

  def active_link_to(text = nil, path = nil, **options, &block)
    link = block_given? ? text : path

    options[:class] = class_names(options[:class], 'nav-link-active') if current_page?(link)

    if block_given?
      link_to(text, options, &block)
    else
      link_to(text, path, options)
    end
  end
end
