module BrownPaperTickets
  class Base
    attr_reader :id, :account, :event, :date, :price
    
    def initialize(id, account)
      @id       = id
      @account  = account
      raise ArgumentError.new("id should not be nil") if @id.nil?
      raise ArgumentError.new("account should not be nil") if @account.nil?
      @event = BrownPaperTickets::Event.new(self.id, self.account)
      @date = BrownPaperTickets::Date.new(self.id, self.account)
      @price = BrownPaperTickets::Price.new(self.id, self.account)
    end
    
    def events
      @event
    end       
    def dates
      @date
    end   
    def prices
      @price
    end
  end
  
end