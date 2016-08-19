# Exceptions that Shark classes will throw for various reasons.
module Shark
  # A generic error, with no extra information about what caused it.
  class Error < StandardError; end

  # Raised when a given Configuration does not meet the expectations of it's
  # schema.
  class ConfigurationError < Error; end
end
