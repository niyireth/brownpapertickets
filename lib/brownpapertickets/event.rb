require 'hpricot'
module BrownPaperTickets
 class Event 
   include HTTParty
   
   base_uri "https://www.brownpapertickets.com/api2" 
   
    attr_reader :attributes
    
    REQUIRED_ATTR=["e_name","e_city","e_state", "e_short_description", "e_description"]
    
    def initialize(id, account, attributes={})
      @@id       = id
      @@account  = account
      @attributes = attributes
    end
    
    def new(params={})
      Event.new(@@id,@@account, params)
    end
    
    def all
      events = Event.get("/eventlist", :query =>{"id" => @@id , "account" => @@account })
      parsed_event = []
      events.parsed_response["document"]["event"].each do |event|
        parsed_event << Event.new(@id,@account, event)
      end
      return parsed_event
    end
    
    def find(event_id)
      event = Event.get("/eventlist", :query =>{"id" => @@id , "account" => @@account, "event_id" => event_id })
      @attributes = event.parsed_response["document"]["event"]
      return self
    end
    
    def method_missing(m, *args, &block)
      if m.to_s.include?("=")
        self.attributes[m.to_s.gsub("=","")] = *args.to_s 
      else
        result = self.attributes[m.to_s]
      end
      #result.respond_to?(:to_str) ? result : NoMethodError.new("Method missing #{m}")
    end
    
    def validates_required_attr
      missing_field = []
      REQUIRED_ATTR.each do |attr|
        missing_field << attr if self.send(attr,nil,nil).blank?
      end
      raise ArgumentError.new("There are some missing attr") unless missing_field.blank?
    end
    
    # Inputs:
    # 
    #    id   -   Developer ID - Available from your Account Settings page.
    #    account  -   Client Login Name - This account must be associated with your Developer Account.
    #    e_name   -   This is the name of the event.
    #    e_city   -   This is the city in which the event is located.
    #    e_state  -   This is the state in which the event is located.
    #    e_short_description  -   This is the short description for the event. Must contain less than 250 characters.
    #    e_description  -   This is the full description for the event.

    #    Optional
    #    e_address1   -   This is the first line of the address at which the event is located. This line is typically used for the venue name. (Optional)
    #    e_address2   -   This is the second line of the address at which the event is located. This line is typically used for the venue address. (Optional)
    #    e_zip  -   This is the zip/postal code of the address at which the event is located. (Optional)
    #    e_phone  -   This is the info line for the event. (Optional)
    #    e_web  -   This is the website for the event. (Optional)
    #    end_of_event_message   -   This is message that is displayed when sales for the event have ended. (Optional)
    #    end_of_sale_message  -   This is message that is displayed to ticket buyers after purchasing tickets for this event.. (Optional)
    #    date_notes   -   These notes are displayed when the user is choosing a date. (Optional)
    #    e_notes  -   These are any general notes that are displayed below the event description. (Optional)
    #    keywords   -   Keywords are not displayed publicly, but are considered when users search for events. (Optional)
    #    c_name   -   This is the name of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_email  -   This is the email address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_phone  -   This is the phone number of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_fax  -   This is the fax number of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_address1   -   This is the first line of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_address2   -   This is the second line of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_city   -   This is the city of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_state  -   This is the state of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_zip  -   This is the zip/postal code of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    c_country  -   This is the country of the mailing address of the person to be contacted about this event. This information is displayed publicly. (Optional)
    #    public   -   "t" or "f". This option is used to list the event in Brown Paper Tickets' public directory or keep it as a private event. Defaults to "t". (Optional)
    #    
    def save!
      validates_required_attr
      body = {"id" => @@id, "account" => @@account}
      query = self.attributes.merge("id" => @@id, "account" => @@account)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/createevent",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      # 	300036 - Required variables are missing
	  	#   300037 - Unknown error while posting info to DB
	  	#   000000 - Success
      case (xml/:resultcode).inner_html
      when "000000" then
        self.event_id = (xml/:event_id).inner_html
       when "300036" then
        raise ArgumentError.new("There are some missing attr")
      when "300037" then
        raise ArgumentError.new("Unknown error while posting info to DB")
      else
        raise ArgumentError.new("Unknown error")
      end
    end
      
    def create(params={})
      event = Event.new(@@id,@@account, params)
      event.save!
    end
      
    def attributes
      @attributes
    end
    
  end
end