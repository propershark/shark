Transport.configure do |config|
  config.wamp = {
    uri:          'ws://io:8080/ws/'
    realm:        'realm1'
    authid:       'tester2'
    authmethods:  ['anonymous']
  }
end
