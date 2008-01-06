require 'test_helper'

class RunitRunnerServiceTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    @config.load do
      set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
      set :deploy_to, 'app_dir'
      set :service_dir, 'service'
      set :runit_sudo_tasks, []
    end
  end
  
  def test_should_create_new_service_using_standard_files
    @config.runit_helper.expects(:run_or_sudo).with('mkdir -p app_dir/service/test_service/log/main')
    @config.runner.expects(:create).with('app_dir/service/test_service', "#!/bin/sh\nrun me", {})
    @config.runner.expects(:create).with('app_dir/service/test_service', "#!/bin/sh\nlog me", {:log_runner => true})
    @config.service.add 'test_service'
  end
  
  def test_should_raise_exception_if_no_runner_template_exists
    @config.runit_helper.expects(:run_or_sudo).with('mkdir -p app_dir/service/foo/log/main')
    assert_raises(RuntimeError) { @config.service.add 'foo' }
  end
  
  def test_should_create_new_service_with_standard_logger_if_logger_template_does_not_exist
    @config.runit_helper.expects(:run_or_sudo).with('mkdir -p app_dir/service/custom_runner_service/log/main')
    @config.runner.expects(:create).with('app_dir/service/custom_runner_service', "#!/bin/sh\nrun me", {})
    @config.runner.expects(:create).with('app_dir/service/custom_runner_service', :log, {:log_runner => true})
    @config.service.add 'custom_runner_service'
  end
  
  def test_should_create_new_service_with_custom_runner_template
    @config.runit_helper.expects(:run_or_sudo).with('mkdir -p app_dir/service/custom_runner_service/log/main')
    @config.runner.expects(:create).with('app_dir/service/custom_runner_service', "custom runner\n", {})
    @config.runner.expects(:create).with('app_dir/service/custom_runner_service', :log, {:log_runner => true})
    @config.service.add 'custom_runner_service', :template => "custom runner\n"
  end
  
  def test_should_create_new_service_with_custom_logger_template
    @config.runit_helper.expects(:run_or_sudo).with('mkdir -p app_dir/service/custom_logger_service/log/main')
    @config.runner.expects(:create).with('app_dir/service/custom_logger_service', "custom runner\n", {})
    @config.runner.expects(:create).with('app_dir/service/custom_logger_service', "custom logger\n", {:log_runner => true})
    @config.service.add 'custom_logger_service', { :template => "custom runner\n" }, { :template => "custom logger\n" } 
  end
end