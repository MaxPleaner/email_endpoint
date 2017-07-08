require 'byebug'

class EmailProcessor

  # @param request [Sinatra::Request]
  # @return [Hash] with keys:
  #   status_code (Integer)
  #   response (Hash)
  def self.run(request)
    filtered_params = filter_params(request.params.with_indifferent_access)
    errors = validate_params(filtered_params)
    status_code, response = if valid?(errors)
      send_email(filtered_params).values_at :status_code, :response
    else
      [422, errors]
    end
    { status_code: status_code, response: response }
  end

  # Per-column validation procs each return an array of error strings
  ParamValidations = {
    to: -> (val) {
      [
        ("invalid email address" if invalid_email?(val)),
        ("no value given" if val.blank?)
      ].compact
    },
    to_name: -> (val) {
      [
        ("no value given" if val.blank?)
      ].compact
    },
    from: -> (val) {
      [
        ("invalid email address" if invalid_email?(val)),
        ("no value given" if val.blank?)
      ].compact
    },
    from_name: -> (val) {
      [
        ("no value given" if val.blank?)
      ].compact
    },
    subject: -> (val) {
      [
        ("no value given" if val.blank?)
      ].compact
    },
    body: -> (val) {
      [
        ("no value given" if val.blank?)
      ].compact
    },
  }

  class << self

    private

    # @param email [String]
    # @return [Boolean] indicating whether it fails the email regex
    #   the regex is taken from https://stackoverflow.com/a/22994329/2981429
    def invalid_email?(email)
      !(email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    end

    # @param params [Hash]
    # @return [Hash], a filtered subset of params
    #   corresponding to the keys in ParamValidations
    def filter_params(params)
      ParamValidations.keys.reduce({}) do |memo, key|
        memo.tap { memo[key] = params[key] }
      end
    end

    # @param params [Hash]
    # @return [Hash] where keys are param names
    #   and values are arrays of errors
    #   Errors are defined by the procs in ParamValidations
    def validate_params(params)
      ParamValidations.reduce({}) do |memo, (name, proc)|
        memo.tap { memo[name] = proc.call(params[name]) }
      end
    end

    # @param errors [Hash] mapping param name to array of errors
    # @return [Boolean] whether all the errors arrays are empty
    def valid?(errors)
      errors.values.all? &:empty?
    end

    # @param body [String] which is HTML
    # @return [String] which is email-safe
    def sanitize_html_for_email(body)
      # TODO
    end

    # @param params [Hash]
    # @return [Hash] with keys:
    #   :status_code (Integer)
    #   :response (Hash)
    def send_email(params)
      { status_code: 200, response: {} }
      # TODO
    end

  end

end