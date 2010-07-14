require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Brownpapertickets" do
  before(:each) do
    @invalid_attributes1 = {
      :id => "citizen_client",
      :account => nil
    }
    @invalid_attributes2 = {
      :id => nil,
      :account => "XsIhXp7K8CknZsC"
    }
    @invalid_attributes3 = {
      :id => nil,
      :account => nil
    }
    @valid_attributes = {
      :account => "citizen_client",
      :id => "XsIhXp7K8CknZsC"
    }
    @bpt = BrownPaperTickets::Base.new(@valid_attributes[:id],@valid_attributes[:account])
  end
  
  it "should Raise an exception when creating a new instance of brownpapertickets with invalid arguments" do
    lambda { BrownPaperTickets::Base.new(@invalid_attributes1[:id],@invalid_attributes1[:account]) }.should raise_error(ArgumentError)
  end
  
  it "should Raise an exception when creating a new instance of brownpapertickets with invalid arguments" do
    lambda { BrownPaperTickets::Base.new(@invalid_attributes2[:id],@invalid_attributes2[:account]) }.should raise_error(ArgumentError)
  end
  
  it "should Raise an exception when creating a new instance of brownpapertickets with invalid arguments" do
    lambda { BrownPaperTickets::Base.new(@invalid_attributes3[:id],@invalid_attributes3[:account]) }.should raise_error(ArgumentError)
  end
  
  it "should get a list of all events" do
    stub_get('https://www.brownpapertickets.com/api2/eventlist?id=XsIhXp7K8CknZsC&account=citizen_client', 'all_events.xml')
    @bpt.events.stub!(:all).and_return(fetch_all_events(HTTParty::Parser.call(fixture_file('all_events.xml'),:xml)["document"]["event"])) 
    bpt = @bpt.events.all
    bpt.size.should == 5
    bpt.first.event_id.should == '106861'
    bpt.first.title.gsub("\n","").should == 'Nichole Canuso Dance Company Second Annual Benefit Cabaret'
    bpt.last.event_id.should == '1068612'
    bpt.last.title.gsub("\n","").should == 'Nichole Canuso Dance Company Second Annual Benefit Cabaret2'
  end 
  
  it "should get a single event" do
    stub_get('https://www.brownpapertickets.com/api2/eventlist?id=XsIhXp7K8CknZsC&account=citizen_client&event_id=106861', 'event.xml')
    @bpt.events.stub!(:find).with(106861).and_return(BrownPaperTickets::Event.new(@id,@account,HTTParty::Parser.call(fixture_file('event.xml'),:xml)["document"]["event"])) 
    bpt = @bpt.events.find(106861)
    bpt.event_id.should == '106861'
    bpt.title.gsub("\n","").should == 'Nichole Canuso Dance Company Second Annual Benefit Cabaret'
  end
  
end
