module CampfireBot
  class Handlers
    def initialize (room, config)
      @config = config
      @room = room
      @handlers = {}
    end
    
    def hear (pattern, &action)
      @handlers[pattern] = action
    end
    
    def load_handlers      
      
      return @handlers
    end
    
    # search Google Images for an image, and return a random result
    def image_me(query)
      base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
      url = "#{base_url}#{URI.encode(query)}"

      resp = Net::HTTP.get_response(URI.parse(url))
      result = JSON.parse(resp.body)

      images = result["responseData"]["results"]
      speak images[rand(images.length)]["unescapedUrl"]
    end
  end
end