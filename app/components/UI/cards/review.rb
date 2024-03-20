# frozen_string_literal: true

class UI::Cards::Review < ViewComponent::Base
  attr_reader :review

  def initialize(review:)
    super
    @review = review
  end

  def avatar
    if review.avatar.present?
      image_tag(review.avatar, class: "w-10 h-10 rounded-full")
    else
      content_tag(:span, review.name[0].upcase, class: "w-10 h-10 flex justify-center items-center rounded-full bg-slate-400")
    end
  end

  def display_avatar_with_name
    content_tag(:div, class: "flex justify-start items-center gap-4") do
      concat(avatar)
      concat(content_tag(:span, review.name, class: ""))
    end
  end

  def display_link_to_review_and_date
    content_tag(:div, class: "flex justify-between items-center gap-8 my-3") do
      concat(
        link_to('https://www.bodas.net/musica/la-gramola-discotecas-moviles--e15600/opiniones', target: 'blank', class: 'flex justify-center items-center bg-slate-300 px-2 h-8 overflow-hidden rounded-xl') do
          inline_svg_tag('icons/brands/bodasnet.svg', class: "w-16 h-16")
        end
      )
      concat(
        content_tag(:span, review.date.strftime('%d-%m-%Y'))
      )
    end
  end

  def display_ratings_with_stars
    full_stars = review.overall_rating.to_i
    partial_star = review.overall_rating - full_stars

    content_tag(:div, class: "flex justify-between items-center gap-4 mt-4 mb-3 text-right") do
      #concat(content_tag(:span, review.overall_rating, class: "inline-block bg-green-500 rounded-full px-2 py-1 text-xs font-semibold text-white"))
      concat(
        content_tag(:div, class: "flex justify-end items-center gap-1") do
          full_stars.times do
            concat(star_svg('text-yellow-300'))
          end
          concat(star_svg('text-yellow-300')) if partial_star >= 0.5
          (5 - full_stars - (partial_star >= 0.5 ? 1 : 0)).times do
            concat(star_svg('text-gray-300'))
          end
        end
      )
    end
  end

  def star_svg(color)
    content_tag(:svg, class: "w-4 h-4 #{color} ms-1", aria: { hidden: true }, xmlns: "http://www.w3.org/2000/svg", fill: "currentColor", viewBox: "0 0 22 20") do
      content_tag(:path, nil, d: "M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z")
    end
  end
end
