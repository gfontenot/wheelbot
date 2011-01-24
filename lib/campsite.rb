module Campfire
  class Campsite
    include HTTParty
  
    def initialize (config)
      Campsite.base_uri   "https://#{config['subdomain']}.campfirenow.com"
      Campsite.basic_auth "#{config['api_key']}", "x"
    end
  
    def rooms
      Campsite.get('/rooms.json')['rooms']
    end
  
    def me
      Campsite.get('/users/me.json')
    end
    
    def room_id_from_name(room_name)
      rooms.each do |room|
        if room["name"] == room_name
          return room["id"]
        end
      end
      
      # if we're here, then we didn't find the room specified. Go ahead and abort the whole process, and alert the user.
      abort "The room named #{room_name} doesn't exist. Either remove it from your config file, or fix the spelling."
    end
  end
end