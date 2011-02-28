require 'hpricot'
module BrownPaperTickets
  class Orderlist 
   include HTTParty
   base_uri "https://www.brownpapertickets.com/api2" 
 
    attr_reader :attributes, :server_response
  
    REQUIRED_ATTR=["date_id", "price_id", "event_id"]
  
    ATTRS=["event_id", "date_id", "price_id"]
  
    def initialize(id, account, attributes={})
      @@id       = id
      @@account  = account
      @attributes = attributes
    end
  
    def new(params={})
      Event.new(@@id,@@account, params, event_id)
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
  
    def create_report
      body = {"id" => @@id, "account" => @@account, "event_id" => event_id, "date_id"=>date_id, "price_id" => price_id}
      query = self.attributes.merge("id" => @@id, "account" => @@account,"event_id" => event_id, "date_id"=>date_id, "price_id" => price_id )
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Get, "https://www.brownpapertickets.com/api2/orderlist",:query => query)
      p response
      response.options[:body] = query
      st = response.perform
      xml = Hpricot(st.response.body)
      p xml
    end
    
    def create(params={})
      date = Event.new(@@id,@@account, params)
      date.save!
    end

    # resultcode
    #  	  300055 - Required variables are missing
    #     300056 - Unknown error
    #     300057 - Unable to find event
    #     300058 - Event does not belong to account
    #     300059 - Unknown error
    #     300060 - Unable to find date
    #     300061 - Required variables are missing
    #     300062 - Unable to update date
    #     000000 -	Success

  
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
        self.date_id = date_id
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