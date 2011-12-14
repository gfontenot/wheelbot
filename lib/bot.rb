BOT_ROOT = File.join(File.dirname(__FILE__), "..")

require 'rubygems'
require 'tinder'

require "#{BOT_ROOT}/lib/handlers"

module CampfireBot
  class Bot
  
    def initialize
    
      @config = YAML::load(File.read("#{BOT_ROOT}/config.yml"))
    
      handlers = Handlers.new
      @handlers = handlers.load_handlers 
    end
    
    def run    
      campsite = Tinder::Campfire.new(@config['subdomain'], :token => @config['api_key'])

      @config['rooms'].each do |room_name|
      
        puts "Joining #{room_name}"
      
        room = campsite.find_room_by_name room_name
        
        Thread.new do
          room.listen do |m|
            if m[:user][:name].to_s != @config['bot_name'] && /^#{@config["bot_name"]}:/i.match(m[:body])
              if /help/i.match(m[:body]) # Print out the help messages for all the active plugins
                room.speak "I listen for the following:"
                @handlers.each_pair do |key, action|
                  if action[:instance].respond_to? "desc_long"
                    action_help = "#{action[:instance].desc_short}: #{action[:instance].desc_long}"
                  elsif action[:instance].respond_to? "desc_short"
                    action_help = action[:instance].desc_short
                  end
                  room.speak action_help
                end
              else                              
                @handlers.each_pair do |key, action|
                  pattern = action[:pattern]
                  if pattern.match(m[:body])
                    action[:instance].perform room, $~
                  end
                end
              end
            end
          end
        end
      end
      
      puts "Listening"
      
      loop do
        # KEEP THE PROC ALIVE YO
        sleep 100
      end

    end
  end
end


def bot
  CampfireBot::Bot.new
end

bot.run