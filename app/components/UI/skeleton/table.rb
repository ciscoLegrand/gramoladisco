class UI::Skeleton::Table < ViewComponent::Base
  def initialize()
    super
  end

  def call
    content_tag :div, role: "status", class: "w-full p-4 space-y-4 divide-y divide-gray-200 rounded shadow animate-pulse dark:divide-gray-700 md:p-6 dark:border-gray-700" do
      concat(render_rows)
      concat(content_tag(:span, 'Loading...', class: 'sr-only'))
    end
  end

  private

  def render_rows
    5.times.map do
      content_tag :div, class: "flex items-center justify-between pt-4 px-12" do
        concat(render_column)
        concat(content_tag(:div, '', class: "h-2.5 bg-gray-300 rounded-full dark:bg-gray-700 w-12"))
      end
    end.join.html_safe
  end

  def render_column
    content_tag :div do
      concat(content_tag(:div, '', class: "w-96 h-2.5 bg-gray-300 rounded-full dark:bg-gray-600 w-24 mb-2.5"))
      concat(content_tag(:div, '', class: "w-32 h-2 bg-gray-200 rounded-full dark:bg-gray-700"))
    end
  end
end
