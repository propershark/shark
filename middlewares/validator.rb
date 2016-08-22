# A simple middleware that only allows events with valid arguments to pass
# through. This only affects arguments that are `Shark::Object` instances,
# and they will be validity will be checked against their schema.
class Validator < Shark::Middleware
  def call event
    # Only proxy the event if it is valid
    fire(event) if event_is_valid?(event)
  end

  def event_is_valid? event
    argument_is_valid?(event.args) && argument_is_valid?(event.kwargs)
  end

  def argument_is_valid? arg
    case arg
    # Object instances must be valid according to their schema
    when Shark::Object
      arg.class.schema.validate(arg)
    # Attempt to validate every argument of container types
    when Array
      arg.all?{ |elem| argument_is_valid?(elem) }
    when Hash
      arg.all?{ |key, val| argument_is_valid?(key) && argument_is_valid?(val) }
    # Any other kind of argument is assumed to be valid
    else
      arg
    end
  end
end
