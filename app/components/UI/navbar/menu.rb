class UI::Navbar::Menu < ViewComponent::Base
  renders_many :nav_items, "UI::Navbar::NavItem"
  renders_one :logo, "UI::Navbar::Logo"
  renders_one :user_section

  def initialize(orientation: :horizontal, style: {})
    super
    @orientation = orientation
    @style = style
  end

  def call
    tag.nav class: "menu #{orientation_class} gap-6 relative #{nav_style}" do
      content
    end
  end

  def nav_style
    @style[:navbar]
  end

  def orientation_class
    @orientation == :vertical ? 'menu-vertical' : 'menu-horizontal'
  end
end
