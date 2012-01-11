require 'mechanize'

module Adapter
  class GithubCrawler
    
    attr_accessor :agent, :search_url

    def initialize
      @agent = Mechanize.new { |a| a.verify_mode = OpenSSL::SSL::VERIFY_NONE; a.user_agent_alias = "Mac Safari" }
      @search_url = "https://github.com/search?type=Users&language=&q=language%3Aa&repo=&langOverride=&x=0&y=0&start_value="
    end

    def crawl
      (1..page_count_for_user_paginated_listing).each do |page_number|
        current_page = @agent.get(url_for(page_number))
        extract_info_from current_page
      end
    end

    private

    def extract_info_from page
      page.search("vcard").each do |dom_element|
        #extract info here
      end
    end

    def page_count_for_user_paginated_listing
      node = @agent.get(url_for_page(@search_url,1)).search(".pagination .pager_link:last-child").last 
      (node.to_s.match(/<a href.*>(.*)<\/a>/)||[])[1]
    end

    def url_for_page url, page_number
      (url+page_number.to_s)
    end

  end
end
