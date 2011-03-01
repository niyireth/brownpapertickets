require 'hpricot'
module BrownPaperTickets
  class Orderlist
   include HTTParty
   base_uri "https://www.brownpapertickets.com/api2" 
 
    attr_reader :attributes, :server_response
  
    REQUIRED_ATTR=["event_id"]
  
    ATTRS=["event_id", "order_time", "quantity", "fname", "lname", "address", "city", "state", "zip", 
      "country", "email", "phone","cc","shipping_method","order_notes","ticket_number", "section", "row","seat",
      "date_id", "price_id"]
  
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
      body = {"id" => @@id, "account" => @@account, "event_id" => event_id}
      query = self.attributes.merge("id" => @@id, "account" => @@account)
      response = BrownPaperTickets::Httpost.new(Net::HTTP::Get, "https://www.brownpapertickets.com/api2/orderlist",:query => query)
      response.options[:body] = query
      st = response.perform
      xml = st.response.body
    end
  
    def server_response
      @server_response
    end
  
    def attributes
      @attributes
    end 
  end
end