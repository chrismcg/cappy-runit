require 'test_helper'

class RunitHelperTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    @config.load do
      set :runner_template_path, File.join(File.dirname(__FILE__), 'templates')
      set :deploy_to, 'app_dir'
      set :service_dir, 'service'
      set :runit_sudo_tasks, [:sudo_task]

      desc "run_task"
      task :run_task do
        runit_helper.run_or_sudo("run")
      end

      desc "sudo_task"
      task :sudo_task do
        runit_helper.run_or_sudo("sudo")
      end
    end
  end
  
  def test_should_run_command
    @config.expects(:run).with("run")
    @config.send :run_task
  end
  
  def test_should_sudo_command
    @config.expects(:sudo).with("sudo")
    @config.send :sudo_task
  end
end