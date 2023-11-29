class UI::Navbar::Logo < ViewComponent::Base
  def initialize(logo_path:, icon_name:, tooltip_text:, action_path:, action_icon_name:)
    super
    @logo_path = logo_path
    @icon_name = icon_name
    @tooltip_text = tooltip_text
    @action_path = action_path
    @action_icon_name = action_icon_name
  end

  def call
    tag.div data: { 'decrease-target': 'logocontainer' },
            class: 'py-1 w-full flex justify-center items-center max-h-20 my-5 gap-5 duration-300 ease-in-out transform transition-all delay-75 border-b-2 border-slate-600' do
      safe_join([logo_link, action_button_with_tooltip])
    end
  end

  private

  def logo_link
    link_to @logo_path do
      inline_svg_tag("#{@icon_name}.svg", data: { 'dark-mode-target': 'sidelogo' }, class: 'max-w-full max-h-20')
    end
  end

  def action_button_with_tooltip
    tag.div data: { controller: 'tooltip' }, class: 'relative flex justify-end' do
      safe_join([action_button, tooltip])
    end
  end

  def action_button
    link_to @action_path,
            data: { tooltip_target: 'tooltip', 'decrease-target': 'arrow_icon', action: 'click->decrease#decrease' },
            class: 'rounded-full w-8 h-8 my-1 flex justify-center content-center items-center bg-gray-300 hover:bg-gray-500 dark:bg-yellow-200 text-white dark:text-black font-bold duration-300 ease-in-out transform transition-all delay-75' do
      image_tag(@action_icon_name, data: { 'decrease-target': 'icon' }, class: 'w-6 h-6 flex justify-center items-center')
    end
  end

  def tooltip
    render(TooltipComponent.new(text: @tooltip_text, position: { vertical: '-bottom-12', horizontal: 'left-0' }))
  end
end
