require 'byebug'

class EmailProcessor

  # @param request [Sinatra::Request]
  # @return [Hash] with keys:
  #   status_code (Integer)
  #   response (Hash)
  def self.run(request)
    filtered_params = filter_params(request.params)
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
    to: -> (val) do
      []
    end,
    to_name: -> (val) do
      []
    end,
    from: -> (val) do
      []
    end,
    from_name: -> (val) do
      []
    end,
    subject: -> (val) do
      []
    end,
    body: -> (val) do
      []
    end,
  }

  class << self

    private

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