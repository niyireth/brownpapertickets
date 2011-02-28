require 'hpricot'
module BrownPaperTickets
  class Price 
   include HTTParty
   base_uri "https://www.brownpapertickets.com/api2" 
 
    attr_reader :attributes, :server_response
  
    REQUIRED_ATTR=["price", "price_name"]
  
    ATTRS=["price", "price_name", "event_id", "date_id", "price_id"]
  
    def initialize(id, account, attributes={})
      @@id       = id
      @@account  = account
      @attributes = attributes
    end
  
    def new(params={})
      Event.new(@@id,@@account, params, event_id, date_id)
    end
  
    def all
      prices = Event.get("/pricelist", :query =>{"id" => @@id , "account" => @@account, "event_id" => event_id , "date_id" => date_id})
      parsed_date = []
      price.parsed_response["document"]["price"].each do |price|
        parsed_date << Event.new(@id,@account, price)
      end
      return parsed_event
    end
  
    def find(event_id)
      price = Event.get("/pricelist",:query =>{"id" => @@id , "account" => @@account, "event_id" => event_id, "date_id"=>date_id})
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
    # 	300042 - Required variables are missing
    #   300043 - Unknown error while fetching event info from DB
    #   300044 - Event does not belong to account
    #   300045 - Unknown error while fetching date info from DB
    #   300046 - Unable to find date
    #   300047 - Unable to add price
    #   0000 - Success.
  
    def save!
      if self.price_id.blank?
        return false unless validates_required_attr
        new_save("addprice")
        p "entro en add price"
      else
        new_save("changeprice")
      end
    end
    
    def new_save(param)
      body = {"id" => @@id, "account" => @@account, "event_id" => event_id, "date_id"=> date_id}
      query = self.attributes.merge("id" => @@id, "account" => @@account)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/#{param}",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
    
      if param == "addprice"
        price_id = (xml/:price_id).inner_html if (xml/:resultcode).inner_html == "000000"
        process_create_response( (xml/:resultcode).inner_html, price_id)
        p price_id
      else
        process_update_response( (xml/:resultcode).inner_html)
      end
    end
    
    def create(params={})
      price = Event.new(@@id,@@account, params)
      price.save!
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
    #  	  300063 - Required variables are missing
    #     300064 - Unable to find event
    #     300065 - Event does not belong to account
    #     300066 - Unknown error
    #     300067 - No such price for this event
    #     300068 - Required variables are missing
    #     300069 - Unable to change price
    #     000000 - Success
  
    def update_attribute(key, value)
      assign = key.to_s + "="
      self.send(assign,value)
      query = {"id" => @@id, "account" => @@account, key.to_s => value, "event_id" => self.event_id}
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changeprice",:query => query)
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
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Post, "https://www.brownpapertickets.com/api2/changeprice",:query => query)
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
      when "300063" then
        @server_response = "Required variables are missing"
        return false
      when "300064" then
        @server_response = "Unable to find event"
        return false
      when "300065" then
        @server_response = "Event does not belong to account"
        return false
      when "300066" then
        @server_response = "Unknown error"
        return false
      when "300067" then
        @server_response = "No such price for this event"
        return false
      when "300068" then
        @server_response = "Required variables are missing"
        return false   
      when "300069" then
        @server_response = "Unable to change price"
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
       when "300042" then
        @server_response = "Required variables are missing"
        return false
      when "300043" then
        @server_response = "Unknown error while posting info to DB"
        return false
      when "300044" then
        @server_response = "Event does not belong to account"
        return false
      when "300045" then
        @server_response = "Unknown error while fetching date info from DB"
        return false
       when "300046" then
          @server_response = "Unable to find date"
          return false
       when "300047" then
          @server_response = "Unable to add price"
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