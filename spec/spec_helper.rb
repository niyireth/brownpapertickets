$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'brownpapertickets'
require 'spec'
require 'spec/autorun'
require "fakeweb"

Spec::Runner.configure do |config|
  
end

def fixture_file(filename)
  return "" if filename == ""
  file_path = File.expand_path(File.dirname(__FILE__) + "/fixtures/" + filename)
  File.read(file_path)
end

def brownpapertickets_url(url)
  url =~ /^https/ ? url : "https://www.brownpapertickets.com/api2#{url}"
end

def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  FakeWeb.register_uri(:get, brownpapertickets_url(url), options)
end


def fetch_all_events(hash_items)
  items = []
  hash_items.each do |item|
    items << BrownPaperTickets::Event.new("id","accoutn", item)
  end
  items
end