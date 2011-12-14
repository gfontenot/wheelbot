require "nokogiri"
require "open-uri"

class Define
   
  def hear
    /define (.*)/i
  end
  
  def desc_short
    "define WORD"
  end
  
  def desc_long
    "Use Google too look up the definition for the given word"
  end
  
  def perform room, matchdata
    define_word(matchdata[1], room)
  end
  
  
  def define_word word, room
    page = Nokogiri::HTML(open("http://www.google.com/search?hl=en&q=define:#{URI.encode(word)}"))
    definition = page.css("ul.std li").first

    room.speak "Can't find the definition of #{word}. Are you sure that it's a word?" if definition.nil?

    room.speak definition.inner_html.gsub('<br>', ' - ').gsub(%r{</?[^>]+?>}, '')
  end
  
  
end