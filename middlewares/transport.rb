require 'yaml'
require 'wamp_client'

class Transport < Shark::Middleware
  # A Hash of configuration data used to define this transport.
  attr_accessor :config
  # The WampClient object that manages the transport session
  attr_accessor :wamp_client
  # The Session object used to publish/subscribe events
  attr_accessor :session
  # The thread that wamp_client will be running in
  attr_accessor :thread

  def initialize app, config_file:
    super(app)
    @config = YAML.load_file(config_file)
    # Create a new WampClient object and add a hook to keep the session
    # object up to date in case of network errors.
    @wamp_client = WampClient::Connection.new(@config['wamp'].symbolize_keys)
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
  def open?
    @wamp_client.is_open? && @session
  end
  alias_method :ready?, :open?

  # Publish public events over the WAMP socket, ignore any other events
  def call event, channel, *args
    case event
    # For now, only these events matter
    when :activate, :deactivate, :update
      puts "Publishing #{event} event to #{channel}"
      @session.publish(channel, args, event: event)
    end

    # This is a pass-through middleware, so proxy the event up.
    @app.call(event, channel, *args)
  end
end
