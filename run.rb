require 'mongoid'
require './profile'
require './user'
require './stackoverflow'
require './crawler'
require './adapters/stackoverflow_crawler'

Mongoid.load!("./mongoid.yml")
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("gc_dev")
end

Crawler.new([Adapter::StackoverflowCrawler.new]).process
