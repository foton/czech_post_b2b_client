# frozen_string_literal: true

module SteppedService
  class Base
    attr_reader :result

    def self.call(*args, **keyword_args)
      new(*args, **keyword_args).call
    end

    # You can override it, to not use steps
    def call
      @finished = false
      @failed = false

      steps.each do |step|
        send(step)
        return self if finished? || failed?
      end
      finish!
      self
    end

    def steps
      %i[need to be implemented]
    end

    def finished?
      finished == true
    end

    def success?
      !failure?
    end

    def failure?
      failed == true
    end
    alias failed? failure?

    def errors
      # use with errors.add(:network, e.message)
      @errors ||= Errors.new
    end

    private

    attr_accessor :finished, :failed

    def finish!
      self.finished = true
    end

    def fail!
      self.failed = true
    end
  end
end
