module SidekiqUniqueJobs
  module OptionsWithFallback
    def unique_enabled?
      options[UNIQUE_KEY] || item[UNIQUE_KEY]
    end

    def unique_disabled?
      !unique_enabled?
    end

    def log_duplicate_payload?
      options[LOG_DUPLICATE_KEY] || item[LOG_DUPLICATE_KEY]
    end

    def lock
      @lock = lock_class.new(item)
    end

    def lock_class
      "SidekiqUniqueJobs::Lock::#{unique_lock.to_s.classify}".constantize
    end

    def unique_lock
      if options.key?(UNIQUE_KEY) && options[UNIQUE_KEY] == true
        warn "unique: true is no longer valid. Please set it to the type of lock required like: `unique: :until_executed`"
        options[UNIQUE_LOCK_KEY] || item[UNIQUE_LOCK_KEY] || SidekiqUniqueJobs.default_lock
      else
        options[UNIQUE_KEY] || item[UNIQUE_KEY] || SidekiqUniqueJobs.default_lock
      end
    end

    def options
      @options ||= worker_class.get_sidekiq_options if worker_class.respond_to?(:get_sidekiq_options)
      @options ||= {}
    end
  end
end