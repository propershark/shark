module Shark
  class AgencyConfiguration < Configuration
    # Specify an ObjectManager that should be created for an Agency. `name` is
    # simply an identifier for the manager (not used anywhere internally).
    # `configurator` is a block that defines configuration for the
    # ObjectManager, and will be passed the `ObjectManagerConfiguration` object
    # of the new ObjectManager instance when executed.
    def managers; @managers ||= []; end
    def use_manager name, &configurator
      managers << [name, configurator]
    end

    # Specify a Middleware class to include in the stack for an Agency. The
    # first middleware defined with this method will be on the top of the stack
    # (last in the chain from the Agency), and each new middleware will appear
    # below the one before it, with the last one being attached directly to the
    # Agency itself.
    # `args`, `**kwargs`, and `&configuration` (all optional) will be passed
    # through to the Middleware's constructor
    def middlewares; @middlewares ||= []; end
    def use_middleware klass, *args, **kwargs, &configuration
      middlewares << [klass, args, kwargs, configuration]
    end
  end
end
