require 'mongoid'
require './profile'
require './user'
require './stackoverflow'
require './github'
require './crawler'
require './adapters/stackoverflow_crawler'
require './adapters/github_crawler'

Mongoid.load!("./mongoid.yml")
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("gc_dev")
end

# Crawler.new([Adapter::StackoverflowCrawler.new]).process
Crawler.new([Adapter::GithubCrawler.new]).process
