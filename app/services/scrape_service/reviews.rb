module ScrapeService
  class Reviews
    def initialize(source:)
      @source = source
      @on_data = nil
    end

    def on_data(&block)
      @on_data = block
    end

    def scrape
      log_with_i18n('scrape_service.reviews.connecting', source: @source)
      doc = Nokogiri::HTML(read_source)

      log_with_i18n('scrape_service.reviews.searching_reviews')
      reviews = []
      persisted_reviews = []

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

        persisted_review = Review.find_by(name: review[:name], date: review[:date], title: review[:title])

        if persisted_review
          persisted_reviews << persisted_review
          log_with_i18n('scrape_service.reviews.existed', date: review[:date])
          next
        end

        log_with_i18n('scrape_service.reviews.processing.name', name: review[:name])
        log_with_i18n('scrape_service.reviews.processing.date', date: review[:date])
        sleep rand(0.5..1.5)
        log_with_i18n('scrape_service.reviews.processing.ratings', ratings: review[:overall_rating].to_json)
        sleep rand(0.5..1.5)
        log_with_i18n('scrape_service.reviews.processing.score', score: review[:ratings])
        sleep rand(0.5..3.5)
        log_with_i18n('scrape_service.reviews.processing.description', description: review[:description])
        sleep rand(0.5..1.5)
        log_with_i18n('scrape_service.reviews.processing.full_data',
          name: review[:name], date: review[:date], score: review[:ratings], description: review[:description], ratings: review[:overall_rating]
        )

        reviews << review                     if persisted_review.nil?
      end

      if reviews.empty?
        log_with_i18n('scrape_service.reviews.not_found')
      else
        Review.insert_all(reviews)
        log_with_i18n('scrape_service.reviews.created', count: reviews.size)
      end

      reviews
    end

    private

    def read_source
      if @source.match?(/^https?:\/\//)
        log_with_i18n('scrape_service.reviews.reading_page_content')
        URI.open(@source)
      else
        log_with_i18n('scrape_service.reviews.reading_local_file')
        File.read(@source)
      end
    end

    def log_with_i18n(key, **kwargs)
      @on_data.call(I18n.t(key, **kwargs)) if @on_data
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
