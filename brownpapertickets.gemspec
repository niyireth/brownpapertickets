$:.push File.expand_path("../lib", __FILE__)
require "brownpapertickets/version"

Gem::Specification.new do |s|
  s.name        = "brownpapertickets"
  s.version     = BrownPaperTickets::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alvaro Insignares", "Niyireth De La Hoz", "Guillermo Iguaran"]
  s.email       = ["alvaro@koombea.com", "niyireth.delahoz@koombea.com", "guilleiguaran@gmail.com"]
  s.homepage    = "http://github.com/niyireth/brownpapertickets"
  s.summary     = %q{Brown Paper Tickets API wrapper}
  s.description = %q{Brown Paper Tickets API wrapper}

  s.rubyforge_project = "brownpapertickets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
  s.add_development_dependency(%q<fakeweb>, ["~> 1.2.0"])
  s.add_runtime_dependency(%q<httparty>, [">= 0.6.1"])
  s.add_runtime_dependency(%q<hpricot>, [">= 0.8.3"])

end
