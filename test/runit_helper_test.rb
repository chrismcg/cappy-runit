require 'test_helper'

class RunitHelperTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @actor = MockConfiguration.new.actor    
    @actor.configuration.set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
    @actor.configuration.set :deploy_to, 'app_dir'
    @actor.configuration.set :service_dir, 'service'
    @actor.configuration.set :runit_sudo_tasks, [:sudo_task]
  end
  
  def test_should_run_command
    @actor.send :run_task
    assert_equal "run", @actor.run_data[0]
    assert_nil @actor.sudo_data
  end
  
  def test_should_sudo_command
    @actor.send :sudo_task
    assert_equal "sudo", @actor.sudo_data[0]
    assert_nil @actor.run_data
  end
end