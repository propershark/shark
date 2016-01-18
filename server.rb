require 'sinatra'
require 'sinatra/activerecord'
require 'activerecord-import'
require 'mysql2'
require 'json'

# ActiveRecord-Import takes some extra setup
require 'activerecord-import/base'
ActiveRecord::Import.require_adapter('mysql2')

# Rack is being a bit weird with thin, making some random asserts. Let's just
# ignore those, shall we?
module Rack
  class Lint
    def assert message, &block
    end
  end
end


# Everything we do here is JSON, so default to returning it.
before do
  if request.request_method == "POST"
    body_parameters = request.body.read
    params.merge!(JSON.parse(body_parameters))
  end
end

# Libraries
Dir[File.join(__dir__, 'lib', '*')].each { |lib| require lib if File.file?(lib) }
# SourcedAttribute sources
Dir[File.join(__dir__, 'sources', '*')].each { |source| require source if File.file?(source) }
# Model Concerns
Dir[File.join(__dir__, 'models', 'concerns', '*')].each{ |concern| require concern if File.file?(concern) }
# Models
Dir[File.join(__dir__, 'models', '*')].each{ |model| require model if File.file?(model) }
# Controllers
Dir[File.join(__dir__, 'controllers', '*')].each{ |ctrl| require ctrl if File.file?(ctrl) }
