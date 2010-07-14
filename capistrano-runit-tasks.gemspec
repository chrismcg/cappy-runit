# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

CAPPY_RUNIT_VERSION = "0.2.4"

Gem::Specification.new do |s|
  s.name        = "capistrano-runit-tasks"
  s.version     = CAPPY_RUNIT_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris McGrath", "Jon Stuart"]
  s.email       = ["chris@octopod.info", "jon@zomo.co.uk"]
  s.homepage    = "http://github.com/chrismcg/cappy-runit"
  s.summary     = "Adds tasks to Capistrano for use with the runit supervision scheme."
  s.description = "This library extends Capistrano to allow processes to be supervised using the runit package. It replaces some of the standard tasks with runit versions and includes tasks and helpers to create the service directory layout and populate it with run scripts. It has support fcgi, mongrel and merb listeners, and tries to make it easy to add other services in your deploy.rb."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "cappy-runit"

  s.files        = Dir.glob("lib/**/*") + %w(README.txt ChangeLog)
  s.require_path = 'lib'
end

