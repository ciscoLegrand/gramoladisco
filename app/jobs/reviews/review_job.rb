module Reviews
  class ReviewJob < ApplicationJob
    queue_as :default

    def perform(source)
      scraper = ScrapeService::Reviews.new(source: source)
      scraper.scrape
    end
  end
end
