require 'doublemap_api'
require_relative '../source.rb'

module DoubleMapSource
  extend Shark::Source


  class Source
    # The name of the agency providing information via doublemap. This should
    # match the subdomain used on doublemap.com
    attr_accessor :agency
    # The name of the attribute used to index the data elements maintained by
    # this source.
    attr_accessor :key
    # The data maintained by this source, stored as a hash, indexed by the
    # primary key attribute given by `key`.
    attr_accessor :data

    def initialize agency:, key:
      @agency   = agency
      @key      = key
      @data     = {}
    end

    def doublemap
      @doublemap ||= begin
        DoubleMap.configure do |config|
          config.base_uri     = "http://#{@agency}.doublemap.com/"
          config.adapter      = :httparty
          config.debug_output = false
        end
        DoubleMap.new
      end
    end
  end
end

# require_relative 'doublemap/route'
# require_relative 'doublemap/station'
# require_relative 'doublemap/vehicle'
