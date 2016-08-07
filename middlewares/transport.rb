require 'json'
require 'wamp_client'
require 'yaml'

class Transport < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self


  # The WampClient object that manages the transport session
  attr_accessor :wamp_client
  # The Session object used to publish/subscribe events
  attr_accessor :session
  # The thread that wamp_client will be running in
  attr_accessor :thread


  def initialize app, *args
    super(app)
    @print_debug = configuration.debug_output
    # Create a new WampClient object and add a hook to keep the session
    # object up to date in case of network errors.
    @wamp_client = WampClient::Connection.new(configuration.wamp.symbolize_keys)
    @wamp_client.on_join{ |session, _| @session = session }
    open
  end

  # Initiate the transport connection in a background thread.
  def open
    @thread = Thread.new{ @wamp_client.open }
  end

  # Return true if the transport is currently connected. Useful for allowing
  # other components to wait until the connection is established, even when
  # it is running in another thread.
  def ready?
    @wamp_client.is_open? && @session
  end
  alias_method :open?, :ready?

  # Publish public events over the WAMP socket.
  # Any event that reaches this middleware will be published over the session.
  def call event, channel, *args, **kwargs
    puts "Transport published `#{event}` to \"#{channel}\" (from \"#{kwargs[:originator]}\", #{args.size} args, #{kwargs.size} kwargs)." if @print_debug
    # Publish the event across the session
    @session.publish(channel, args, event: event, originator: kwargs[:originator])
    # This is a pass-through middleware, so proxy the event up.
    @app.call(event, channel, *args, kwargs)
  end
end
