class EmailProvider

  # A container which components get added to dynamically.
  # Use {.register} to do so.
  # See the lib/email_providers/ folder for builtin provider APIs
  Providers = {}

  # It isn't necessary for provider components to inherit from this protocol,
  # but it can be done so to ensure that all required methods are defined.
  class Protocol
    # @param params [Hash]
    # @raise [RuntimeError], but this method is expected to be redefined.
    #   it should return a Hash with status_code (Int) and response (Hash) keys
    # The 'response' isn't really used here (it always returns an empty hash).
    # Rather, the 'status_code' key is used to detect the result.
    def self.send_email(params); raise("not implemented"); end
  end

  # @param class_or_module [Class] which implenents EmailProvider::Protocol
  # @return [void]
  def self.register(class_or_module)
    Providers[class_or_module.to_s.split("::").last.to_sym] = class_or_module
  end

  attr_reader :provider

  # @param provider_name [Symbol] should be a key in the Providers hash
  # @return [EmailProvider] with #send_email delegated to the provider
  def initialize(provider_name)
    @provider = self.class::Providers[provider_name]
    define_singleton_method :send_email, &provider.method(:send_email)
  end

end