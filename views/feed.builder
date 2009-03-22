xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@feed.title)
    xml.description(@feed.description)
    xml.language('en-us')

    for entry in @feed.entries
      xml.item do
        xml.title(entry.title)
        xml.description(entry.summary)
        xml.pubDate(entry.published)
#        xml.link(entry.link)
#        xml.guid(entry.guid)
      end
    end
  }
}

