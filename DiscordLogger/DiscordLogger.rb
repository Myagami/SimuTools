require 'dotenv'
require 'discordrb'
Dotenv.load
class DiscordLogger
  @Logger
  def initialize
    @Logger = Discordrb::Commands::CommandBot.new token: ENV['CLIENT_SECRET'], client_id: ENV['CLIENT_ID'] , prefix: '!'
  end
end
