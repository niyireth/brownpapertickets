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
event.e_zip = "90210"
event.e_name = "Test Event"
event.e_city = "Beverly Hills"
event.e_state = "CA"
event.e_short_description = " this is a test"
event.e_description = "this is a test"
event.save!
puts "New Event: #{event.event_id}"
puts event.validates_required_attr