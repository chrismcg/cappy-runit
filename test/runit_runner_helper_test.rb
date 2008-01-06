require 'test_helper'

class RunitRunnerHelperTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    @config.load do
      set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
      set :deploy_to, 'app_dir'
      set :runit_sudo_tasks, []
    end
  end
  
  def test_should_load_runit_runner_helper
    assert Capistrano.const_get(:EXTENSIONS).include?(:runner)    
  end
  
  def test_should_create_default_fcgi_runner
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/standard_fcgi_runner")
    @config.expects(:put).with(expected, 'test/output/run', :mode => 0700)
    @config.runner.create 'test/output', :fcgi, :listener_port => 8000
  end

  def test_should_create_default_mongrel_runner
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/standard_mongrel_runner")
    @config.expects(:put).with(expected, 'test/output/run', :mode => 0700)
    @config.runner.create 'test/output', :mongrel, :listener_port => 8000
  end
  
  def test_should_create_custom_runner
    custom_runner = "<%= foo %>"
    @config.expects(:put).with("bar", 'test/output/run', :mode => 0700)
    @config.runner.create 'test/output', custom_runner, :foo => 'bar'
  end

  def test_should_create_log_runner
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/log_runner")
    @config.expects(:put).with(expected, 'test/output/log/run', :mode => 0700)
    @config.runner.create 'test/output', :log
  end
  
  def test_should_create_custom_log_runnner
    custom_runner = "<%= foo %>"
    @config.expects(:put).with('bar', 'test/output/log/run', :mode => 0700)
    @config.runner.create 'test/output', custom_runner, :log_runner => true, :foo => 'bar'
  end
  
  def test_should_create_runner_from_file_template
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/standard_fcgi_runner")
    @config.expects(:put).with(expected, 'test/output/run', :mode => 0700)
    @config.runner.create 'test/output', 'test_runner', :listener_port => 8000
  end

  def test_should_create_log_runner_from_log_file_template
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/log_runner")
    @config.expects(:put).with(expected, 'test/output/log/run', :mode => 0700)
    @config.runner.create 'test/output', 'test_log_runner', :log_runner => true
  end
end