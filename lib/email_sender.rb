require 'byebug'

require_relative "./email_provider.rb"
require_relative "./email_providers/sendgrid_api.rb"

class EmailSender

  # See lib/email_provider.rb for options
  DefaultProviderName = :SendGridAPI

  # Depends on the #payload method being dynamically defined in a before_action
  # (see server.rb)
  # @param request [Sinatra::Request]
  # @return [Hash] with keys:
  #   status_code (Integer)
  #   response (Hash)
  def self.run(request, provider_name=DefaultProviderName)
    filtered_params = filter_params(request.payload.with_indifferent_access)
    errors = validate_params(filtered_params)
    status_code, response = if valid?(errors)
      filtered_params[:sanitized_html] = sanitize_html(filtered_params[:body])
      email_result = send_email(filtered_params, provider_name)
      email_result.values_at :status_code, :response
    else
      [422, errors]
    end
    { status_code: status_code, response: response }
  end

  # This is not called automatically by {.run}.
  # @param body [String] which is HTML
  # @return [String] which is email-safe
  def self.sanitize_html(html)
    html # TODO
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



    # @param params [Hash]
    # @return [Hash] with keys:
    #   :status_code (Integer)
    #   :response (Hash)
    def send_email(params, provider_name)
      EmailProvider.new(provider_name).send_email(params)
    end

  end

end