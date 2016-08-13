module Shark
  class Event
    # The topic this event is being fired on
    attr_accessor :topic
    # The type of event being represented
    attr_accessor :type
    # The positional arguments for this event
    attr_accessor :args
    # The keyword arguments for this event
    attr_accessor :kwargs
    # The object that caused the creation of this event
    attr_accessor :originator

    def initialize topic:, type:, args:[], kwargs:{}, originator:
      @topic      = topic
      @type       = type
      @args       = args
      @kwargs     = kwargs
      @originator = originator
    end
  end
end
