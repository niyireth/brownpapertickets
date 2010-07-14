module BrownPaperTickets
class Xmlparse < HTTParty::Parser
  
  def initialize(body, format)
    @body = body
    @format = format
  end
  
  def parse
    perform_parsing
  end
end
end
