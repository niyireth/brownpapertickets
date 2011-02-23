require 'hpricot'
module BrownPaperTickets
 class Event 
   include HTTParty
   
   base_uri "https://www.brownpapertickets.com/api2" 
   
    attr_reader :attributes, :server_response
    
    REQUIRED_ATTR=["e_name","e_city","e_state", "e_short_description", "e_description"]
    
    ATTRS=["e_name","e_city","e_state", "e_short_description", "e_description","e_address1","e_address2","e_zip","e_phone","e_web","end_of_event_message",
            "end_of_sale_message","date_notes","e_notes","keywords","c_name","c_email","c_phone","c_fax","c_address1","c_address2","c_city","c_state","c_zip",
            "c_country","public", "title","link", "description", "event_id", "tickets_sold"]
    
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
      event_sales = Event.get("/eventsales", :query =>{"id" => @@id , "account" => @@account })
       p "*"*12
      p event_sales
      parsed_event = []
      events.parsed_response["document"]["event"].each do |event|
        parsed_event << Event.new(@id,@account, event)
      end
      return parsed_event
    end
    
    def find(event_id)
      event = Event.get("/eventlist",:query =>{"id" => @@id , "account" => @@account, "event_id" => event_id })
      event_sales=Event.get("/eventsales",:query =>{"id" => @@id , "account" => @@account, "event_id" => event_id })
      p "*"*12
      p event_sales
      @attributes = event.parsed_response["document"]["event"]
      return self
    end
    
    def method_missing(m, *args, &block)
      if ATTRS.include?(m.to_s.gsub("=",""))
        if m.to_s.include?("=")
          self.attributes[m.to_s.gsub("=","")] = *args.to_s
        else
          result = self.attributes[m.to_s]
        end
      else
        raise NoMethodError.new("Method missing #{m}")
      end
    end
    
    def validates_required_attr
      missing_field = []
      REQUIRED_ATTR.each do |attr|
        missing_field << attr if self.send(attr,nil,nil).blank?
      end
      unless missing_field.blank?
        @server_response = "The following attributes are missing:"
        missing_field.each{|att| @server_response = @server_response + " " + att }
        return false
      end
      return true
    end
    
    #   Response while saving
    # 	300036 - Required variables are missing
  	#   300037 - Unknown error while posting info to DB
  	#   000000 - Success
    
    def save!
      if self.event_id.blank?
        #changeevent
        return false unless validates_required_attr
        new_save("createevent")
      else
        #createevent
        new_save("changeevent")
      end
    end
      
    def new_save(param)    
      body = {"id" => @@id, "account" => @@account}
      query = self.attributes.merge("id" => @@id, "account" => @@account)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/#{param}",:query => query)
      response1 = BrownPaperTickets::Httpost.new(Net::HTTP::Get, "https://www.brownpapertickets.com/api2/eventsales",:query => query)
      p "*"*12
      p response1
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      
      if param == "createevent"
        event_id = (xml/:event_id).inner_html if (xml/:resultcode).inner_html == "000000"
        process_create_response( (xml/:resultcode).inner_html, event_id)
      else
        process_update_response( (xml/:resultcode).inner_html)
      end
    end  
    
    def title=(param)
      self.attributes["e_name"] = param
      self.attributes["title"]  = param
    end
    
    def e_name=(param)
      self.attributes["e_name"] = param
      self.attributes["title"]  = param
    end
      
    def create(params={})
      event = Event.new(@@id,@@account, params)
      event.save!
    end
      
    def live
      return true if self.attributes["live"] == "y"
      return false
    end
    
    def live=(param)
      if param
        self.attributes["live"] = "y"
      else
        self.attributes["live"] = "f"
      end 
    end  
      
    def public
      return true if self.attributes["public"] == "t"
      return false
    end

    def public=(param)
      if param
        self.attributes["public"] = "t"
      else
        self.attributes["public"] = "n"
      end 
    end  
    
    # resultcode
    #  	  300049 - Required variables are missing
    # 	  300050 - Unknown error
    #	  	300051 - Unable to find event
    #	  	300052 - Event does not belong to account
    #	  	300053 - Required variables are missing
    #	  	300054 - Unable to update event
    #     000000 - Success
    
    def update_attribute(key, value)
      assign = key.to_s + "="
      self.send(assign,value)
      query = {"id" => @@id, "account" => @@account, key.to_s => value, "event_id" => self.event_id}
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changeevent",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      return process_update_response((xml/:resultcode).inner_html)
    end
    
    def update_attributes(params)
      params.each do |key, value|
        assign = key.to_s + "="
        self.send(assign,value)
      end
      query = {"id" => @@id, "account" => @@account,  "event_id" => self.event_id}.merge(params)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changeevent",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      return process_update_response((xml/:resultcode).inner_html)
    end
    
    def process_update_response(response)
      case response
      when "000000" then
        @server_response = "success"
        return true
      when "300049" then
        @server_response = "Required variables are missing"
        return false
      when "300050" then
        @server_response = "Unknown error"
        return false
      when "300051" then
        @server_response = "Unable to find event"
        return false
      when "300052" then
        @server_response = "Event does not belong to account"
        return false
      when "300053" then
        @server_response = "Required variables are missing"
        return false
      when "300054" then
        @server_response = "Unable to update event"
        return false      
      else
        @server_response = "Unknown error"
        return false                            
      end
    end
    
    def process_create_response(response, event_id)
      case response
      when "000000" then
        self.event_id = event_id
        @server_response = "success"
        return true
       when "300036" then
        @server_response = "There are some missing attr"
        return false
      when "300037" then
        @server_response = "Unknown error while posting info to DB"
        return false
      else
        @server_response = "Unknown error"
        return false
      end
    end
    
    def server_response
      @server_response
    end
    
    def attributes
      @attributes
    end
    
  end
end