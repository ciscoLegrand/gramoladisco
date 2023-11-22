class UI::Logo < ViewComponent::Base
  def initialize(link:, logo:)
    @link = link
    @logo = logo
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
