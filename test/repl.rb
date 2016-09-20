require 'ripl'

module Shark
  BINDING = binding

  module Test
    class REPL < Shark::Middleware
      EVENT_HISTORY_LENGTH = 25

      attr_accessor :events
      attr_accessor :event_handlers

      def initialize app=nil, *args
        super
        @events = Hash.new{ |h, k| h[k] = [] }
        @event_handlers = Hash.new{ |h, k| h[k] = Proc.new{} }

        Thread.new{ Ripl.start(binding: binding) }
      end

      def call event
        @events[event.topic].unshift(event)
        @events[event.topic].pop if @events[event.topic].length > EVENT_HISTORY_LENGTH

        # Instantiate and execute a handler for the event based on its namespace.
        self.instance_exec(@events[event.topic], &@event_handlers[[event.topic, event.type]])
      end

      # Register a callback to execute when an event comes in.
      #
      # Callbacks are registered based on a topic and event type. Example:
      #   on 'vehicles.4002', :update do
      #     puts "Got an update event"
      #   end
      def on topic, type, &block
        @event_handlers[[topic, type]] = block
      end
    end
  end
end
