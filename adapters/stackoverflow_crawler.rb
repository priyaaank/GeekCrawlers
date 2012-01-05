require 'mechanize'

module Adapter
  class StackoverflowCrawler

    attr_accessor :agent, :page_count, :url
    
    def initialize
      @agent = Mechanize.new {|a| a.user_agent_alias = 'Mac Safari' }
      @page_count = 18441
      @url = "http://stackoverflow.com/users?tab=reputation&filter=all&page="
    end

    def crawl
      (1..@page_count).each do |page_number|
        current_page = @agent.get(url_for(page_number))
        extract_info_from current_page
      end
    end

    private

    def extract_info_from page
      page.search(".user-details").each do |dom_element|
        location   = extract_location_from dom_element
        url, name  = extract_url_and_name_from dom_element
        reputation = extract_reputation_from dom_element
        provider_id, handle = url.split("/")[2..3]
        create_user_with_profile(name, url, location, provider_id, handle, reputation)
      end
    end

    def create_user_with_profile name, url, location, provider_id, handle, reputation
      stackoverflow_profile = Stackoverflow.new(:location => location, :handle => handle, 
                                                :reputation => reputation, :provider_id => provider_id, 
                                                :url => url)
      user = User.new(:name => name)
      user.save!
      user.profiles << stackoverflow_profile
    end

    def url_for page_number
      (@url + page_number.to_s)
    end

    def extract_location_from dom_element
      ((dom_element.search(".user-location") || "").to_s.match(/<span class="user-location">(.*)<\/span>/) || [])[1]
    end

    def extract_url_and_name_from dom_element
      (dom_element.search("a").to_s.match(/<a href="(.*)">(.*)<\/a>/) || [])[1..2]
    end

    def extract_reputation_from dom_element
      ((dom_element.search(".reputation-score") || "").to_s.match(/<span[a-zA-Z\s"\-=0-9]+>(.*)<\/span>/) || [])[1]
    end

  end
end
