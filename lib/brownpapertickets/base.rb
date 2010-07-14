module BrownPaperTickets
  class Base
    attr_reader :id, :account, :event  
    
    def initialize(id, account)
      @id       = id
      @account  = account
      raise ArgumentError.new("id should not be nil") if @id.nil?
      raise ArgumentError.new("account should not be nil") if @account.nil?
      @event = BrownPaperTickets::Event.new(self.id, self.account)
    end
    
    def events
      @event
    end
   
    
  end
  
end