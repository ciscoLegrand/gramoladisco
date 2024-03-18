module Reviews
  class ReviewJob < ApplicationJob
    queue_as :default

    def perform(user_id:)
      endpoint = Rails.application.credentials.dig(:scrape, :url)

      broadcast_log(I18n.t('reviews.job.start', endpoint: endpoint, user_id: user_id))

      scraper = ScrapeService::Reviews.new(source: endpoint)
      scraper.on_data do |log_message|
        broadcast_log(log_message)
      end

      scraper.scrape
      broadcast_log(I18n.t('reviews.job.end'))
    end

    private

    def broadcast_log(message)
      Turbo::StreamsChannel.broadcast_prepend_to ["reviews_channel", current_user.to_gid_param].join(":"),
        target: "reviews_logs",
        partial: "admin/reviews/log",
        locals: { log: message }
    end

    def current_user
      @current_user ||= User.find(self.arguments.first[:user_id])
    end
  end
end
