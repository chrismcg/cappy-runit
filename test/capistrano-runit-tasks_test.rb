$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

class CappyRunitTasksConfigurationTest < Test::Unit::TestCase
  class MockActor
    attr_reader :tasks

    def initialize(config)
    end

    def define_task(*args, &block)
      (@tasks ||= []).push [args, block].flatten
    end
  end

  def setup
    @config = Capistrano::Configuration.new(MockActor)
    file = File.dirname(__FILE__) + "/fixtures/runit_config.rb"
    @config.load file
  end  

  def test_should_include_capistrano_runit_tasks
    assert task_names(@config.actor.tasks).include?(:setup_service_dirs)
  end
  
  def task_names(tasks)
    tasks.map { |task| task[0] }
  end
end


