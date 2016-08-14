require 'set'

# A Middleware class for sending related events for each event that passes
# through it. For example, an `update` event on a Vehicle will cause a
# `vehicle_update` to go out on the Route that the vehicle is traveling.
class Conductor < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self

  def initialize app, *args
    super(app)
    @objects_with_changed_associations = Set.new
  end

  # While Conductor is mostly implemented as event handlers, it also tracks
  # changes to associations between objects, and sends out `update` events for
  # each object whose associations have changed while executing the event
  # handler.
  #
  # These `update` events will go out *after* the original event, since `super`
  # calls `fire(event)`.
  def call event
    super

    # For each object whose associations changed while handling this event,
    # fire an `update` event, with the original event as it's originator.
    @objects_with_changed_associations.each do |object|
      # Do not send another `update` for the Object that the original event was
      # created for.
      next if object.identifier == event.topic

      fire(Shark::Event.new(
        topic: object.identifier,
        type: :update,
        args: [object],
        kwargs: {},
        originator: event.topic
      ))
    end

    # Clear the list of changed objects to prepare for the next event.
    @objects_with_changed_associations.clear
  end

  # Create an association on `base` to the argument given by `to`. If `base` is
  # not an Object instance, attempt to locate the Object instance it represents
  # in `@storage`.
  # `to` should be either an Object instance or the identifier for one.
  #
  # If a call causes a change to `base.associated_objects`, it will be added to
  # the list of changed objects for which `update` events will be sent.
  def associate base, to:, type: Shark::Object
    # Determine the identifier string for `to` to be used for the association
    # on `base`.
    to_type       = to.is_a?(Shark::Object) ? to.class      : type
    to_identifier = to.is_a?(Shark::Object) ? to.identifier : to
    # Resolve the Object `base` represents. If it cannot be resolved, the
    # association can not be created, so return false.
    return false unless base = resolve_object(base)
    # `base` should now be an Object instance, so create the association
    associations_did_change = base.associate(to_type, to_identifier)
    @objects_with_changed_associations.add(base) if associations_did_change
    associations_did_change
  end

  # The reverse of `associate`, remove the association to `from` from `base`.
  def dissociate base, from:, type: Shark::Object
    # Determine the identifier string for `from` to be used for the association
    # on `base`.
    from_type       = from.is_a?(Shark::Object) ? from.class      : type
    from_identifier = from.is_a?(Shark::Object) ? from.identifier : from
    # Resolve the Object `base` represents. If it cannot be resolved, the
    # association can not be created, so return false.
    return false unless base = resolve_object(base)
    # `base` should now be an Object instance, so create the association
    associations_did_change = base.dissociate(from_type, from_identifier)
    @objects_with_changed_associations.add(base) if associations_did_change
    associations_did_change
  end

  # Create a bi-directional association between `base` and `other`. That is,
  # create an association to `other` on `base`, and to `base`, on `other`.
  def associate_mutual base, other
    # Resolve the Object instance for both `base` and `other`.
    base  = resolve_object(base)
    other = resolve_object(other)
    # Only continue if both objects were successfully found.
    return false unless base && other

    # Associate the objects
    associate(base,   to: other)
    associate(other,  to: base)
  end

  # The reverse of `associate_mutual`.
  def dissociate_mutual base, other
    # Resolve the Object instance for both `base` and `other`.
    base  = resolve_object(base)
    other = resolve_object(other)
    # Only continue if both objects were successfully found.
    return false unless base && other

    # Dissociate the objects
    dissociate(base,  from: other)
    dissociate(other, from: base)
  end
end


# Include event-handling modules.
# This pattern allows these modules to access instance variables like `@app`
# and `@storage` without having to pass them around.
require_relative 'conductor/route_events'
require_relative 'conductor/station_events'
require_relative 'conductor/vehicle_events'
