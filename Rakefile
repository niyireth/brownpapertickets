require 'rubygems'
require 'bundler'

$:.push File.expand_path("../lib", __FILE__)
require "brownpapertickets/version"

Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = BrownPaperTickets::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "brownpapertickets #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
