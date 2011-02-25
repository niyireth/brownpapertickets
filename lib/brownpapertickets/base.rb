# This is a API wrapper for brownpapersticker service.
# The purpose of this is gem is to behave like ActiveRecord
# in the creation of an event.
#
# Author::    Alvaro Insignares  (mailto:alvaro@koombea.com) Niyireth De La Hoz (mailto:niyireth.delahoz@koombea.com)
# Copyright:: Copyright (c) 2010 Koombea, Ltda
# License::   Distributes under the same terms as Ruby

module BrownPaperTickets
  class Base
    attr_reader :id, :account, :event, :date, :price
    
    # Needs the brownpapersticker's credentials (id and account),
    # creates a new instance of event, date and price
    def initialize(id, account)
      @id       = id
      @account  = account
      raise ArgumentError.new("id should not be nil") if @id.nil?
      raise ArgumentError.new("account should not be nil") if @account.nil?
      @event = BrownPaperTickets::Event.new(self.id, self.account)
      @date = BrownPaperTickets::Date.new(self.id, self.account)
      @price = BrownPaperTickets::Price.new(self.id, self.account)
    end
    
    # Returns the event
    def events
      @event
    end       
    # Return the date
    def dates
      @date
    end   
    # Return the price
    def prices
      @price
    end
  end
  
end