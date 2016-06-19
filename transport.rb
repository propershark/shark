require 'wamp_client'

module Shark
  class Transport
    # The WampClient object that manages the transport session
    attr_accessor :wamp_client
    # The Session object used to publish/subscribe events
    attr_accessor :session
    # The thread that wamp_client will be running in
    attr_accessor :thread

    # Parameters used to initialize the WAMP client
    # TODO: Include this in the service config.
    WAMP_PARAMS = {
      uri: 'ws://io:8080/ws',
      realm: 'realm1',
      authid: 'tester2',
      authmethods: ['anonymous']
    }

    def initialize
      # Create a new WampClient object and add a hook to keep the session
      # object up to date in case of network errors.
      @wamp_client = WampClient::Connection.new(WAMP_PARAMS)
      @wamp_client.on_join{ |session, _| @session = session }
    end

    # Initiate the transport connection in a background thread.
    def open
      @thread = Thread.new{ @wamp_client.open }
    end

    # Return true if the transport is currently connected. Useful for allowing
    # other components to wait until the connection is established, even when
    # it is running in another thread.
    def is_open?
      @wamp_client.is_open?
    end

    # A direct wrapper around `session.publish` to avoid needing to update
    # references to `session` (it will be changed whenever a new session opens)
    def publish channel, args=[], kwargs={}
      @session.publish(channel, args, kwargs)
    end
  end
end
