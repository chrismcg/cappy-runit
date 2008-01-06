require 'test_helper'

class RunitRunnerServiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @actor = TestActor.new(MockConfiguration.new)    
    @actor.configuration.set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
    @actor.configuration.set :deploy_to, 'app_dir'
    @actor.configuration.set :service_dir, 'service'
    @actor.configuration.set :runit_sudo_tasks, []
  end
  
  def test_should_create_new_service_using_standard_files
    @actor.service.add 'test_service'
    assert_equal 'mkdir -p app_dir/service/test_service/log/main', @actor.run_data[0]
    assert_equal "#!/bin/sh\nrun me", @actor.put_data['app_dir/service/test_service/run'], @actor.put_data.inspect
    assert_equal "#!/bin/sh\nlog me", @actor.put_data['app_dir/service/test_service/log/run'], @actor.put_data.inspect
  end
  
  def test_should_raise_exception_if_no_runner_template_exists
    assert_raises(RuntimeError) { @actor.service.add 'foo' }
  end
  
  def test_should_create_new_service_with_standard_logger_if_logger_template_does_not_exist
    @actor.service.add 'custom_runner_service'
    assert_equal 'mkdir -p app_dir/service/custom_runner_service/log/main', @actor.run_data[0]
    assert_equal "#!/bin/sh\nrun me", @actor.put_data['app_dir/service/custom_runner_service/run'], @actor.put_data.inspect
    assert_equal "#!/bin/sh -e\nexec svlogd -t ./main\n", @actor.put_data['app_dir/service/custom_runner_service/log/run'], @actor.put_data.inspect
  end
  
  def test_should_create_new_service_with_custom_runner_template
    @actor.service.add 'custom_runner_service', :template => "custom runner\n"
    assert_equal 'mkdir -p app_dir/service/custom_runner_service/log/main', @actor.run_data[0]
    assert_equal "custom runner\n", @actor.put_data['app_dir/service/custom_runner_service/run'], @actor.put_data.inspect
    assert_equal "#!/bin/sh -e\nexec svlogd -t ./main\n", @actor.put_data['app_dir/service/custom_runner_service/log/run'], @actor.put_data.inspect        
  end
  
  def test_should_create_new_service_with_custom_logger_template
    @actor.service.add 'custom_logger_service', { :template => "custom runner\n" }, { :template => "custom logger\n" } 
    assert_equal 'mkdir -p app_dir/service/custom_logger_service/log/main', @actor.run_data[0]
    assert_equal "custom runner\n", @actor.put_data['app_dir/service/custom_logger_service/run'], @actor.put_data.inspect
    assert_equal "custom logger\n", @actor.put_data['app_dir/service/custom_logger_service/log/run'], @actor.put_data.inspect
  end
end