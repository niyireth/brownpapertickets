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
  
  it "should raise a exception that is missing an attr" do
    event = @bpt.events.new
    lambda {event.save!}.should raise_error(ArgumentError)
  end
  
  it "should raise a exception that is missing an attr" do
    lambda {@bpt.events.create({})}.should raise_error(ArgumentError)
  end
  
  it "Should save the event" do
    resp = mock("resp")
    resp2 = mock("resp2")
    resp3 = mock("resp3")
    resp.stub!(:options).and_return({})
    resp.stub!(:perform).and_return(resp2)
    resp2.stub!(:response).and_return(resp3)
    resp3.stub!(:body).and_return(fixture_file('create_ok.xml'))
    BrownPaperTickets::Httpost.stub!(:new).and_return(resp)
    event = @bpt.events.new("e_zip" => "90210", "e_name"=>"test", "e_city"=> "Sprinfield", "e_state"=>"CA", "e_short_description"=>"this is a test", "e_description"=>"this is a test")
    event.save!
    event.event_id.should == "120266"
  end
  
  it "Should not save the event and rise a ArgumentError" do
    resp = mock("resp")
    resp2 = mock("resp2")
    resp3 = mock("resp3")
    resp.stub!(:options).and_return({})
    resp.stub!(:perform).and_return(resp2)
    resp2.stub!(:response).and_return(resp3)
    resp3.stub!(:body).and_return(fixture_file('create_not_ok.xml'))
    BrownPaperTickets::Httpost.stub!(:new).and_return(resp)
    event = @bpt.events.new("e_zip" => "90210", "e_name"=>"test", "e_city"=> "Sprinfield", "e_state"=>"CA", "e_short_description"=>"this is a test", "e_description"=>"this is a test")
    lambda {event.save!}.should raise_error(ArgumentError)
  end
  
end
