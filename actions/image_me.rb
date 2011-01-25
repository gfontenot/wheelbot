class Image_Me < CampfireBot::Action
  
  hear /image me (.+)/i do |matchdata|
    image_me(matchdata[1])
  end
  
  def image_me(query)
    base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
    url = "#{base_url}#{URI.encode(query)}"
    
    resp = Net::HTTP.get_response(URI.parse(url))
    result = JSON.parse(resp.body)

    images = result["responseData"]["results"]
    return images[rand(images.length)]["unescapedUrl"]
  end
end