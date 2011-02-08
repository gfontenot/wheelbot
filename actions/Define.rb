require "nokogiri"
require "open-uri"

class Define
  
  def initialize room
    @room = room
  end
  
  def hear
    /define (.*)/i
  end
  
  def perform matchdata
    define_word(matchdata[1])
  end
  
  
  def define_word word
    page = Nokogiri::HTML(open("http://www.google.com/search?hl=en&q=define:#{URI.encode(word)}"))
    definition = page.css("ul.std li").first

    @room.speak "None found" if definition.nil?

    @room.speak definition.inner_html.gsub('<br>', ' - ').gsub(%r{</?[^>]+?>}, '')
  end
  
  
end