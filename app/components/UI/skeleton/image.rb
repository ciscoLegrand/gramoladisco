class UI::Skeleton::Image < ViewComponent::Base
  def initialize()
    super
  end

  def call
    content_tag(:div, class: "w-full flex items-center justify-center h-72 bg-gray-300 rounded-lg animate-pulse dark:bg-gray-700") do
      concat photo_svg
      concat loading_span
    end
  end

  def photo_svg
    inline_svg_tag 'icons/photo.svg', class: 'w-12 h-12 text-gray-400 dark:text-gray-600'
  end

  def loading_span
    content_tag :span, 'loading...', class: 'sr-only'
  end
end
