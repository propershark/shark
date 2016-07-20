require_relative '../middlewares/transport'

Transport.configure do |config|
  config.wamp = {
    uri:          'ws://io:8080/ws/',
    realm:        'realm1',
    authid:       'tester2',
    authmethods:  ['anonymous']
  }

  # Set to true to output a line to STDOUT for every event that passes through
  # the Transport middleware.
  config.debug_output = true
end
