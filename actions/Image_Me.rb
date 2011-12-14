class Image_Me
  
  def hear
    /image me (.+)/i
  end
  
  def perform room, matchdata
    unless room.name == "The Office"
      get_image(matchdata[1], room)
    end
  end
  
  def desc_short
    "image me PHRASE"
  end
  
  def desc_long
    "Perform a google image search for the phrase and return a random result"
  end

  def get_image(query, room)
    base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
    url = "#{base_url}#{URI.encode(query)}"
  
    resp = Net::HTTP.get_response(URI.parse(url))
    result = JSON.parse(resp.body)

    images = result["responseData"]["results"]
  
    room.speak "#{images[rand(images.length)]["unescapedUrl"]}#.png"
  end
  
end