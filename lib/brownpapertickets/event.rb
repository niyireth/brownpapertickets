module BrownPaperTickets
 class Event 
   include HTTParty
   
   base_uri "https://www.brownpapertickets.com/api2" 
   
    attr_reader :id, :account, :attributes
    
     def initialize(id, account, attributes={})
        @id       = id
        @account  = account
        @attributes = attributes
      end
    
    def all
      events = Event.get("/eventlist", :query =>{"id" => @id, "account" => @account })
      parsed_event = []
      events.parsed_response["document"]["event"].each do |event|
        parsed_event << Event.new(@id,@account, event)
      end
      return parsed_event
    end
    
    def find(event_id)
      event = Event.get("/eventlist", :query =>{"id" => @id, "account" => @account, "event_id" => event_id })
      @attributes = event.parsed_response["document"]["event"]
      return self
    end
    
    def method_missing(m, *args, &block)
      result = self.attributes[m.to_s]
      #result.respond_to?(:to_str) ? result : NoMethodError.new("Method missing #{m}")
    end
    
    
    
    def attributes
      @attributes
    end
    
  end
end