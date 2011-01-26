class Image_Me < CampfireBot::Action
  
  hear /image me (.+)/i do |matchdata|
    # get_image(matchdata[1])
    base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
    url = "#{base_url}#{URI.encode(matchdata[1])}"
    
    resp = Net::HTTP.get_response(URI.parse(url))
    result = JSON.parse(resp.body)

    images = result["responseData"]["results"]
    
    speak images[rand(images.length)]["unescapedUrl"]
  end
  
  def get_image(query)
    base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
    url = "#{base_url}#{URI.encode(query)}"
    
    resp = Net::HTTP.get_response(URI.parse(url))
    result = JSON.parse(resp.body)

    images = result["responseData"]["results"]
    
    speak "#{images[rand(images.length)]["unescapedUrl"]}#.png"
  end
end