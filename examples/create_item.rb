require File.join(File.dirname(__FILE__), '..', 'lib', 'brownpapertickets')

@valid_attributes = {
  :account => "citizen_client",
  :id => "XsIhXp7K8CknZsC"
}
@bpt = BrownPaperTickets::Base.new(@valid_attributes[:id],@valid_attributes[:account])

event = @bpt.events.new()
#    e_name   -   This is the name of the event.
#    e_city   -   This is the city in which the event is located.
#    e_state  -   This is the state in which the event is located.
#    e_short_description  -   This is the short description for the event. Must contain less than 250 characters.
#    e_description  -   This is the full description for the event.
#["e_name","e_city","e_state", "e_short_description", "e_description","e_address1","e_address2","e_zip","e_phone","e_web","end_of_event_message",
#        "end_of_sale_message","date_notes","e_notes","keywords","c_name","c_email","c_phone","c_fax","c_address1","c_address2","c_city","c_state","c_zip",
#        "c_country","public", "title","link", "description", "event_id"]
event.e_zip = "90210"
event.e_name = "Test Event"
event.e_city = "Beverly Hills"
event.e_state = "CA"
event.e_short_description = " this is a test"
event.e_description = "this is a test"
event.save!
puts "New Event: #{event.event_id}"
puts event.validates_required_attr