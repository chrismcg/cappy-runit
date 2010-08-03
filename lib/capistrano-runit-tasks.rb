$:.unshift File.dirname(__FILE__)
require 'runit_helper'
require 'runit_runner_helper'
require 'runit_command_helper'
require 'runit_service_helper'

Capistrano::Configuration.instance(:must_exist).load do
  set :service_dir, 'service'
  set :listener_count, 1
  set :listener_type, :mongrel
  set :master_service_dir, '~/service'
  set :service_root, variables[:deploy_to]
  set :listener_base_port, 9000
  set :sv_command, :sv # can be :sv or :runsvctrl
  set :runner_template_path, File.join('templates', 'runit')
  set :runit_sudo_tasks, []
   
  namespace :deploy do
    desc "Sets up services directories for supervising listeners using runit"
    task :setup_service_dirs do
      application_service_dir = "#{service_root}/#{service_dir}"
      runit_helper.run_or_sudo "mkdir -p #{application_service_dir}"

      each_listener do |listener_port|
        # DEPRECATION: Need to pass port and fcgi_port to handle old templates, fcgi_port is considered deprecated
        service.add listener_port, :template => listener_type, :listener_port => listener_port, :fcgi_port => listener_port
      end
    end

    desc "Links created service dir into master service dir so runit starts the listeners"
    task :start, :roles => :app do
      each_listener do |listener_port|
        service_dir = "#{service_root}/#{service_dir}/#{listener_port}"
        runit_helper.run_or_sudo "ln -nsf #{service_dir} #{master_service_dir}/#{application}-#{listener_port}"    
      end
    end

    desc "restart task for runit supervised listeners"
    task :restart, :roles => :app do
      sv.usr2 listener_dirs      
    end

    desc "Hook into after setup to create the runit service directory"
    task :post_setup do
      setup_service_dirs
    end
    after :setup, "deploy:post_setup"

    def each_listener
      listener_base_port.upto(listener_base_port + listener_count - 1) do |listener_port|
        yield listener_port
      end
    end

    def listener_dirs
      dirs = []
      each_listener { |port| dirs << "#{service_root}/#{service_dir}/#{port}" }
      dirs
    end
  end
end
