require 'gmail' # Can read mail from Gmail

# A wrapper over a SmtpServer.
# The server isn't actually launched here, and there is no capacity to delete
# or send messages. The only thing this does is read messages.
class SmtpServer

  # Instance, connected to a specific account, used to read messages
  attr_reader :gmail

  # @param username [String], should belong to a Gmail address
  # @param password [String]
  # Password shouldn't really be a secret here. It's used for the test cases.
  def initialize(username, password)
    @gmail = Gmail.connect username, password
  end

  # @return [Array<Mail::Message>]
  # marks messages as read once they are seen
  def fetch_unread
    gmail.inbox.find(:unread).map do |email|
      msg = email.message
      email.delete!
      msg
    end
  end

end