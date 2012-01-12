require 'mechanize'
require 'cgi'

module Adapter
  class GithubCrawler
    
    def initialize
      @agent = Mechanize.new { |a| a.verify_mode = OpenSSL::SSL::VERIFY_NONE; a.user_agent_alias = "Mac Safari" }
      @search_url = "https://github.com/search?type=Users&language=&q=language%3Aa&repo=&langOverride=&x=0&y=0&start_value="
      @github_url = "https://github.com"
    end

    def crawl
      (1..page_count_for_user_paginated_listing).each do |page_number|
        current_page = @agent.get(url_for_page(@search_url, page_number))
        users_from(current_page).each do |user_handle|
          user_profile_page = @agent.get("#{@github_url}#{user_handle}")
          extract_info_from user_profile_page, user_handle
        end
        puts "Done with page #{page_number}"
      end
    end

    private

    def users_from page
      page.search(".title a").collect do |user_profile|
        match_value(user_profile, /<a href="(.*)".*/)
      end
    end

    def extract_info_from page, handle
      profile_node = page.search(".vcard").first
      
      name = extract_name_from profile_node, ".fn", /<dd.*>(.*)<\/dd>/
      location = extract_location_from profile_node, ".locality", /<dd.*>(.*)<\/dd>/
      blog = extract_blog_from profile_node, ".url a", /<a.*>(.*)<\/a>/
      employer = extract_employer_from profile_node, ".org", /<dd.*>(.*)<\/dd>/
      email = decode_email(extract_email_from(profile_node,".email a", /<a.*data-email="(.*)"\s+href=.*<\/a>/))
      handle = handle.split("/").last

      
      repo_node, followers_node = page.search(".stats li a")
      repo_count = extract_count_from repo_node, "strong:first", /<strong>(.*)<\/strong>/
      followers = extract_follower_count_from followers_node, "strong:last", /<strong>(.*)<\/strong>/

      create_user_with_profile(name, location, handle, blog, employer, email, repo_count, followers)
    end

    def create_user_with_profile name, location, handle, blog, employer, email, repo_count, followers
      github_profile = Github.new( :followers => followers, :repo_count => repo_count, :blog => blog,
                                   :handle => handle, :provider_id => handle, :location => location,
                                   :profile_name => name)
      user = (!email.nil? && User.where(:email => email).first) || User.create!(:name => name, :email => email)
      user.profiles << github_profile
    end

    def page_count_for_user_paginated_listing
      node = @agent.get(url_for_page(@search_url,1)).search(".pagination .pager_link:last-child").last 
      match_value(node, /<a href.*>(.*)<\/a/).to_i
    end

    def url_for_page url, page_number
      (url+page_number.to_s)
    end

    def match_value(node, regex)
      (node.to_s.match(regex) || [])[1]
    end

    def method_missing(method_name, *args, &block)
      if(method_name.to_s.start_with?("extract_"))
        if args.length > 2
          node_value_from args[0], args[1], args[2] 
        end
      end
    end

    def node_value_from node, css_selector, regex
      return nil if node.nil?
      selected_text = node.search(css_selector).last
      selected_text.nil? ? nil : match_value(selected_text, regex)
    end

    def decode_email email_data
      email_data.nil? ? nil : CGI::unescape(email_data)
    end

  end
end
