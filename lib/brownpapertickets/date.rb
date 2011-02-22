require 'hpricot'
module BrownPaperTickets
  class Date 
   include HTTParty
   base_uri "https://www.brownpapertickets.com/api2" 
 
    attr_reader :attributes, :server_response
  
    REQUIRED_ATTR=["begin_time", "end_time", "sales_end", "max_sales"]
  
    ATTRS=["begin_time", "end_time", "event_id", "date_id", "sales_end", "max_sales"]
  
    def initialize(id, account, attributes={})
      @@id       = id
      @@account  = account
      @attributes = attributes
    end
  
    def new(params={})
      Event.new(@@id,@@account, params, event_id)
    end
  
    def all
      dates = Event.get("/datelist", :query =>{"id" => @@id , "account" => @@account})
      parsed_date = []
      date.parsed_response["document"]["date"].each do |date|
        parsed_date << Event.new(@id,@account, date)
      end
      return parsed_event
    end
  
    def find(event_id)
      date = Event.get("/datelist",:query =>{"id" => @@id , "account" => @@account, "event_id" => event_id, "date_id"=>date_id})
      @attributes = event.parsed_response["document"]["date"]
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
      if self.date_id.blank?
        #changeevent
        return false unless validates_required_attr
        new_save("adddate")
      else
        #createevent
        new_save("changedate")
      end
    end
    
    def new_save(param)
      body = {"id" => @@id, "account" => @@account, "event_id" => event_id}
      query = self.attributes.merge("id" => @@id, "account" => @@account)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/#{param}",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)    
      if param == "adddate"
        p "algo"*12
        self.date_id = (xml/:date_id).inner_html if (xml/:resultcode).inner_html == "000000"
        process_create_response( (xml/:resultcode).inner_html, date_id)
        p date_id
        p event_id
      else
        process_update_response( (xml/:resultcode).inner_html)
      end
    end  
    
    def create(params={})
      date = Event.new(@@id,@@account, params)
      date.save!
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
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changedate",:query => query)
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
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changedate",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      return process_update_response((xml/:resultcode).inner_html)
    end
  
    def process_update_response(response)
      case response
      when "000000" then
        @server_response = "Success"
        return true
      when "300055" then
        @server_response = "Required variables are missing"
        return false
      when "300056" then
        @server_response = "Unknown error"
        return false
      when "300057" then
        @server_response = "Unable to find event"
        return false
      when "300058" then
        @server_response = "Event does not belong to account"
        return false
      when "300059" then
        @server_response = "Unknown error"
        return false
      when "300060" then
        @server_response = "Unable to find date"
        return false   
      when "300061" then
        @server_response = "Required variables are missing"
        return false
      when "300062" then
        @server_response = "Unable to update date"
        return false   
      else
        @server_response = "Unknown error"
        return false                            
      end
    end
  
    def process_create_response(response, event_id)
      case response
      when "0000" then
        self.event_id = event_id
        @server_response = "success"
        return true
       when "300038" then
        @server_response = "Required variables are missing"
        return false
      when "300039" then
        @server_response = "Unknown error while posting info to DB"
        return false
      when "300040" then
        @server_response = "Event does not belong to user"
        return false
      when "300041" then
        @server_response = "Unable to add date"
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