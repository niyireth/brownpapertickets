require File.join(File.dirname(__FILE__), '..', 'lib', 'brownpapertickets')

@valid_attributes = {
  :account => "your_account",
  :id => "your_id"
}
@bpt = BrownPaperTickets::Base.new(@valid_attributes[:id],@valid_attributes[:account])

event = @bpt.events.find(120405)

event.update_attribute(:e_name, "This Awsome Title")

puts "*"*100
puts event.e_name
puts "*"*100

puts event.server_response

event.update_attributes({:e_name => "This Awsome Title2",:e_address1 => "Evergreen av 123", :e_phone => "5553335588"})

puts "*"*100
puts event.e_name
puts event.e_address1
puts event.e_phone
puts "*"*100

puts event.server_response
 
event.e_name = "This Super Awsome Title2"
event.e_address1 = "Evergreen av 123 nxt to homer"
event.e_phone = "2365476235"

puts event.save!

puts "*"*100
puts event.e_name
puts event.e_address1
puts event.e_phone
puts "*"*100