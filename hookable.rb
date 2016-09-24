module Shark
  # Give any class the ability to define before/after hooks. Note that only one
  # block can be specified for a given hook.
  module Hookable
    def self.included base
      base.extend(ClassMethods)
    end

    module ClassMethods
      def hooks
        @hooks ||= {}
      end

      def before method, &block
        hooks["before_#{method}"] = block
      end

      def after method, &block
        hooks["after_#{method}"] = block
      end
    end

    def before method
      fire_callback("before_#{method}")
    end

    def after method
      fire_callback("after_#{method}")
    end

    private
      def fire_callback name
        callback = self.class.hooks[name]
        instance_exec(&callback) if callback
      end
  end
end
