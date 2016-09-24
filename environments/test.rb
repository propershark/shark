require_relative '../test/repl'

module Shark
  class TestEnvironment < Environment
    cli_name :test

    def initialize options
      super
      puts "In the Test Environment"
    end

    # Remove any middlewares that publish events to the real world, and insert
    # the REPL middleware before finalizing the stack.
    before(:finalize) do
      remove_middleware Transport
      insert_middleware Test::REPL, after: options[:insert_after]
    end
  end
end
