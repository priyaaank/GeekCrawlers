require 'mechanize'

module Adapter
  class GithubCrawler
    
    attr_accessor :language_listing_url, :agent, :languages, :search_url

    def initialize
      @language_listing_url = "http://github.com/languages"
      @agent = Mechanize.new { |a| a.verify_mode = OpenSSL::SSL::VERIFY_NONE; a.user_agent_alias = "Mac Safari" }
      @languages = []
      @search_url = "https://github.com/search?langOverride=&language=&q=language%3A##LANGUAGE_NAME##&repo=&type=Users&x=19&y=21&start_value="
    end

    def crawl
      populate_language_list
      @languages.each do |language|
        crawl_users_who_code_in language
      end
    end

    private

    def crawl_users_who_code_in language
      puts "#{language} : #{page_count_for(language)}"
    end

    def populate_language_list
      @languages = language_page.search(".right ul li a").collect do |language_url|
        matched_language_name_from language_url
      end
    end

    def matched_language_name_from language_url
      (language_url.to_s.match(/<a href.*>(.*)<\/a>/) || [])[1]
    end

    def language_page
      @agent.get(@language_listing_url)
    end

    def url_for language, page_number
      (@search_url.gsub("##LANGUAGE_NAME##",language) + page_number.to_s)
    end

    def page_count_for language
      node = @agent.get(url_for(language,1)).search(".pagination .pager_link:last-child").last 
      (node.to_s.match(/<a href.*>(.*)<\/a>/)||[])[1]
    end

  end
end
