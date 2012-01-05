class Crawler

  attr_accessor :adapters

  def initialize(adapters = [])
    @adapters = adapters
  end

  def process
    @adapters.map(&:crawl)
  end

end
