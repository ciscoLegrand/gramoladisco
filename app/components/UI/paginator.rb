class UI::Paginator < ViewComponent::Base
  def initialize(items:, url:)
    @items = items
    @url = url
  end

  def call
    content_tag :div, data: { controller: 'dropdown', 'dropdown-value': { open: 'false' } }, class: 'relative w-12 h-12 bg-gray-950 rounded-xl  shadow-lg shadow-gray-950 flex justify-center items-center' do
      concat button
      concat dialog
    end
  end

  private

  def button
    content_tag :button, role: 'button', tabindex: 0, data: { 'dropdown-target': 'openButton', action: 'click->dropdown#open' }, class: 'w-10 h-10 z-50' do
      content_tag :span, class: 'text-lg text-slate-white font-semibold hover:cursor-pointer' do
        @items
      end
    end
  end

  def dialog
    content_tag :dialog, data: { 'dropdown-target': 'dropdownContent' }, class: 'absolute -bottom-[11rem] right-7 z-40 w-full flex flex-col gap-6 hidden border-2 border-gray-950 text-slate-200 shadow-lg shadow-slate-500 shadow-t-none rounded-lg rounded-t-none p-4 bg-gray-950 opacity-0 transition-opacity duration-300 ease-in-out' do
      content_tag :div, class: 'flex flex-col justify-center items-center gap-5' do
        ['10', '25', '50', '100', '500'].each do |item|
          next if @items.eql? item
          concat link_to(item, @url.call(items: item), data: { turbo: 'search_results' },class: 'font-semibold hover:cursor-pointer hover:scale-125 hover:text-blue-400 hover:transition-all hover:duration-300 hover:ease-in-out transition-all duration-300 ease-in-out')
        end
      end
    end
  end
end
