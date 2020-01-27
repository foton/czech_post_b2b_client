# frozen_string_literal: true

module SteppedService
  class Errors < Hash
    def add(key, value, _opts = {})
      self[key] ||= []
      self[key] << value
      self[key].uniq!
    end

    def add_from_hash(errors_hash)
      errors_hash.each do |key, values|
        values.each { |value| add key, value }
      end
    end

    def full_messages
      f_msgs = []
      each_one { |field, message| f_msgs << "#{field}: #{message}" }
      f_msgs
    end

    def each_one
      each_pair do |field, messages|
        messages.each { |message| yield field, message }
      end
    end
  end
end
