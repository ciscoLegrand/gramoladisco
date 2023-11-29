class UI::Navbar::NavItem < ViewComponent::Base
  def initialize(path:, icon: nil, title:)
    @path = path
    @icon = icon
    @title = title
  end

  def call
    content = [title_content]
    content << icon_content if @icon.present?
    active_link_to(@path, data: { 'decrease-target': 'link'}, class: 'nav-link w-full flex justify-start items-center py-2 px-10 transition-all ease-in-out duration-1000') do
      safe_join(content)
    end
  end

  private

  def title_content
    content_tag(:span, @title, class: 'w-full text-lg transition-all ease-in-out duration-1000', data: { 'decrease-target': 'title' })
  end

  def icon_content
    inline_svg_tag(@icon, class: 'w-8 h-8', data: { 'decrease-target': 'iconLeft' }) if @icon
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
