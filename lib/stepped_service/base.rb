# frozen_string_literal: true

# Service class based on steps chain (see #steps), which can be successfull even with errors.
# If execution of step is successful, next step will be executed.
# Step can be marked as failed by calling #fail!. That will stop executing steps chain and return as #failed?.
# During processing, #errors can be added, but they will not stop the execution.
#
# Example usage
#
#    class TeaMaker < SteppedService::Base
#      attr_reader :tea_type, :bags_into_kettle
#      def initialize(tea_type:, bags_into_kettle:)
#        @tea_type = tea_type
#        @bags_into_kettle = bags_into_kettle
#      end
#
#      def steps
#        %i[get_water_into_kettle
#          make_it_boil
#          put_tea_bags_into_kettle
#          wait_3mins
#          pour_tea_into_cups
#          add_sugar_to_caps]
#      end
#
#      private
#
#      attr_accessor :teabags, :kettle, :cups
#
#      def get_water_into_kettle
#        self.kettle = find_kettle
#        unless kettle
#          errors.add(:kettle, "There is no kettle in kitchen!")
#          fail!
#        end
#        fill_water_into(kettle)
#      end
#
#      def make_it_boil
#        ...
#      end
#
#      def put_tea_bags_into_kettle
#        self.teabags = get_teabags(tea_type, bags_into_kettle)
#        if teabags.empty?
#          errors.add(:teabags, "There is no #{bags_into_kettle} #{tea_type} tea teabags in storage," \
#                               "  using fruit tea teabags.")
#          self.teabags = get_teabags(:fruit, bags_into_kettle)
#          if teabags.empty?
#            errors.add(:teabags, "There is no #{bags_into_kettle} fruit tea teabags in storage either!")
#            fail!
#          end
#        end
#        insert(teabags, to: kettle)
#      end
#
#      ...
#
#      def add_sugar_to_caps # last step should fill @result
#         cups.each{ |c| c.insert(sugar_cube) }
#         @result = cups
#      end
#    end
#
# calling
#    teamaker = TeaMaker.call(:black, 2)
# will return instance of with:
# - if there is no kettle :
#     teamaker.failure? # => true
#     teamaker.result # => nil
#     teamaker.errors[:kettle] # => ["There is no kettle in kitchen!"]
# - if there is no black tea but fruit was found:
#     teamaker.success? # => true
#     teamaker.result # => _cups with fruit tea_
#     teamaker.errors[:teabags] # => ["There is no 2 :black tea teabags in storage, using fruit tea teabags."]
# - if there is no black or fruit tea:
#     teamaker.success? # => false
#     teamaker.result # => nil
#     teamaker.errors[:teabags] # => ["There is no 2 :black tea teabags in storage, using fruit tea teabags.",
#                                     "There is no 2 fruit tea teabags in storage either!"]
# - if all goes well:
#     teamaker.success? # => true
#     teamaker.result # => _cups with black tea_
#     teamaker.errors # => {}
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
