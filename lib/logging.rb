module Logging
  def tagger_log(tag, log)
    Rails.logger.tagged("[#{tag.upcase}] 🩹🩹") { log.call }
  end

  def debug_log(message)
    Rails.logger.debug "🐞🐞 [DEBUG]: #{message} 🐞🐞\n\n"
  end

  def info_log(message)
    Rails.logger.info "👀👀 [INFO]: #{message} 👀👀\n\n"
  end

  def warn_log(message)
    Rails.logger.warn "⚠️⚠️ [WARN]: #{message} ⚠️⚠️\n\n"
  end

  def error_log(message)
    Rails.logger.error "❌❌ [ERROR]: #{message} ❌❌\n\n" 
  end

  def fatal_log(message)
    Rails.logger.fatal "💀💀 [FATAL]: #{message} 💀💀\n\n" 
  end

  def log_with_metadata(tag, level, message, metadata={})
    metadata_part = metadata.map { |key, value| "#{key}=#{value}" }.join(" ")
    public_send("#{level}_log", "[#{tag}] #{message} #{metadata_part}")
  end
end
