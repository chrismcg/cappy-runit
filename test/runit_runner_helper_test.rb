require 'test_helper'

class RunitRunnerHelperTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @actor = TestActor.new(MockConfiguration.new)    
    @actor.configuration.set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
    @actor.configuration.set :deploy_to, 'app_dir'
    @actor.configuration.set :runit_sudo_tasks, []
  end
  
  def test_should_load_runit_runner_helper
    assert Capistrano.const_get(:EXTENSIONS).include?(:runner)    
  end
  
  def test_should_create_default_fcgi_runner
    @actor.runner.create 'test/output', :fcgi, :listener_port => 8000
    assert_equal File.read("#{File.dirname(__FILE__)}/fixtures/standard_fcgi_runner"), @actor.put_data['test/output/run']
  end

  def test_should_create_default_mongrel_runner
    @actor.runner.create 'test/output', :mongrel, :listener_port => 8000
    assert_equal File.read("#{File.dirname(__FILE__)}/fixtures/standard_mongrel_runner"), @actor.put_data['test/output/run']
  end
  
  def test_should_create_custom_runner
    custom_runner = "<%= foo %>"
    @actor.runner.create 'test/output', custom_runner, :foo => 'bar'
    assert_equal 'bar', @actor.put_data['test/output/run']
  end

  def test_should_create_log_runner
    @actor.runner.create 'test/output', :log
    assert_equal File.read("#{File.dirname(__FILE__)}/fixtures/log_runner"), @actor.put_data['test/output/log/run']
  end
  
  def test_should_create_custom_log_runnner
    custom_runner = "<%= foo %>"
    @actor.runner.create 'test/output', custom_runner, :log_runner => true, :foo => 'bar'
    assert_equal 'bar', @actor.put_data['test/output/log/run']    
  end
  
  def test_should_create_runner_from_file_template
    @actor.runner.create 'test/output', 'test_runner', :listener_port => 8000
    assert_equal File.read("#{File.dirname(__FILE__)}/fixtures/standard_fcgi_runner"), @actor.put_data['test/output/run']
  end

  def test_should_create_log_runner_from_log_file_template
    @actor.runner.create 'test/output', 'test_log_runner', :log_runner => true
    assert_equal File.read("#{File.dirname(__FILE__)}/fixtures/log_runner"), @actor.put_data['test/output/log/run']
  end
end