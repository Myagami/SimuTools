require 'dotenv'
Dotenv.load
class DiscordLogger
  def initialize
      puts ENV['CLIENT_ID']
  end
end
