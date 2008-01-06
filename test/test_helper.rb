begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end
require 'rubygems'
require 'mocha'

require 'test/unit'
$:.unshift File.dirname(__FILE__) + "/../lib", File.dirname(__FILE__)
require 'runit_command_helper'
require 'runit_helper'
require 'runit_runner_helper'
require 'runit_service_helper'
