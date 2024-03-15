module ScrapeService
  class Reviews
    def initialize(source:)
      @source = source
    end

    def scrape
      doc = Nokogiri::HTML(read_source)
      reviews = []

      doc.css('.storefrontReviewsTileSubpage').each do |review_element|
        name_date_text = review_element.at_css('.storefrontReviewsTileInfo')&.text&.strip
        name, date = name_date_text.split("Enviado el").map(&:strip)
        review = {
          avatar: review_element.at_css('.avatar__img img')&.attr('src'),
          name: name,
          date: Date.strptime(date, '%d/%m/%Y'),
          overall_rating: review_element.at_css('.rating__count')&.text&.strip.to_f,
          ratings: extract_ratings(review_element),
          title: review_element.at_css('.storefrontReviewsTileContent__title')&.text&.strip,
          description: review_element.at_css('.storefrontReviewsTileContent__description')&.text&.strip,
        }
        reviews << review
      end

      reviews
    end

    private

    def read_source
      if @source.match?(/^https?:\/\//)
        URI.open(@source)
      else
        File.read(@source)
      end
    end

    def extract_ratings(review_element)
      ratings = {}
      review_element.css('.storefrontReviewsAverage__rating li').each do |rating_element|
        category = rating_element.text.split.first
        rating = rating_element.at_css('.ratingSingleLine__count')&.text&.strip.to_f
        ratings[category] = rating
      end
      ratings
    end
  end
end
