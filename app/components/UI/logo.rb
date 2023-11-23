class UI::Logo < ViewComponent::Base
  def initialize(link:, logo:)
    @link = link
    @logo = logo
  end

  def call
    content_tag(:div, class: 'w-full h-16 flex justify-center items-center content-center') do
      link_to(logo_tag, @link, class: 'flex items-center justify-center my-3')
    end
  end

  def logo_tag
    if svg?(@logo)
      inline_svg_tag(@logo, class: 'w-12 h-12')
    else
      image_tag(@logo, class: 'w-12 h-12')
    end
  end

  private

  def svg?(filename)
    File.extname(filename).downcase == '.svg'
  end
end
