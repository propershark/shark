module Shark
  module Test
    # This module assumes a Hash of events, keyed by topic, called `@events`,
    # and a Hash of event handlers, keyed by topic/event type, called
    # `@event_handlers`.
    module DSL
      # Register a callback to execute when an event comes in.
      #
      # Callbacks are registered based on a topic and event type. Example:
      #   on 'vehicles.4002', :update do
      #     puts "Got an update event"
      #   end
      def on topic, type, &block
        @event_handlers[[topic, type]] = block
      end

      # Retrieve the last event of the given type published to the given topic.
      #
      # Example:
      #   last :update, to: 'vehicles.4002'
      def last type, to:
        @events[to].find{ |event| event.type == type }
      end

      # Resolve the object instance for the given topic. If there is no
      # matching object in the current Storage adapter, return nil.
      def fetch topic
        Storage.adapter.find(topic)
      end
    end
  end
end
