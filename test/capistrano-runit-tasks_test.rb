$:.unshift File.dirname(__FILE__) + "/../lib"

require 'test/unit'
begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

class CappyRunitTasksConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    file = File.dirname(__FILE__) + "/fixtures/runit_config.rb"
    @config.load file
  end  

  def test_should_include_capistrano_runit_tasks
    assert_not_nil @config.find_task("deploy:setup_service_dirs")
  end
  
  def task_names(tasks)
    tasks.map { |task| task[0] }
  end
end


