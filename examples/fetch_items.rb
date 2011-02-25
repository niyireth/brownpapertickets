require File.join(File.dirname(__FILE__), '..', 'lib', 'brownpapertickets')

@valid_attributes = {
  :account => "your_account",
  :id => "your_id"
}
@bpt = BrownPaperTickets::Base.new(@valid_attributes[:id],@valid_attributes[:account])

event = @bpt.events.find(106861)

puts "Title: #{event.title}"
puts "Event id: #{event.event_id}"
puts "E zip: #{event.e_zip}"

event.e_zip = "hola"
puts "Live: #{event.live}"


puts "E zip: #{event.e_zip}"
puts "fetching all... this could take a while ..."

events = @bpt.events.all

puts "this is the result:"
event = events.first

puts "Title: #{event.title}"
puts "Event id: #{event.event_id}"
puts "E zip: #{event.e_zip}"

event = events.last
puts "Title: #{event.title}"
puts "Event id: #{event.event_id}"
puts "E zip: #{event.e_zip}"