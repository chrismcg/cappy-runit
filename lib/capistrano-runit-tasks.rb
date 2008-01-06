$:.unshift File.dirname(__FILE__)
require 'runit_helper'
require 'runit_runner_helper'
require 'runit_command_helper'
require 'runit_service_helper'

Capistrano.configuration(:must_exist).load do
  set :service_dir, 'service'
  set :listener_count, 1
  set :listener_type, :mongrel
  set :master_service_dir, '~/service'
  set :listener_base_port, 9000
  set :sv_command, :sv # can be :sv or :runsvctrl
  set :runner_template_path, File.join('templates', 'runit')
  set :runit_sudo_tasks, []
   
  # We need our own task for this as the default cold_deploy
  # calls restart, which won't work until we've setup the 
  # symlink, perhaps we could add a test to restart to check if the
  # link exists, but that's beyond my current (very bad) shell-foo 
  desc "Used only for deploying when the services haven't been setup"
  task :cold_deploy do
    handle_deprecated_vars
    transaction do
      update_code
      symlink
    end
    spinner
  end

  desc "Sets up services directories for supervising listeners using runit"
  task :setup_service_dirs do
    handle_deprecated_vars
    application_service_dir = "#{deploy_to}/#{service_dir}"
    runit_helper.run_or_sudo "mkdir -p #{application_service_dir}"
        
    each_listener do |listener_port|
      # DEPRECATION: Need to pass port and fcgi_port to handle old templates, fcgi_port is considered deprecated
      service.add listener_port, :template => listener_type, :listener_port => listener_port, :fcgi_port => listener_port
    end
  end
    
  desc "Links created service dir into master service dir so runit starts the listeners"
  task :spinner do
    handle_deprecated_vars
    each_listener do |listener_port|
      service_dir = "#{deploy_to}/#{service_dir}/#{listener_port}"
      runit_helper.run_or_sudo "ln -sf #{service_dir} #{master_service_dir}/#{application}-#{listener_port}"    
    end
  end
  
  desc "restart task for runit supervised listeners"
  task :restart, :roles => :app do
    handle_deprecated_vars
    sv.usr2 listener_dirs      
  end
  
  desc "Hook into after setup to create the runit service directory"
  task :after_setup do
    handle_deprecated_vars
    setup_service_dirs
  end

  def each_listener
    listener_base_port.upto(listener_base_port + listener_count - 1) do |listener_port|
      yield listener_port
    end
  end
  
  def listener_dirs
    dirs = []
    each_listener { |port| dirs << "#{deploy_to}/#{service_dir}/#{port}" }
    dirs
  end
  
  ## DEPRECATED - and alias_method won't work inside the instance_eval this is run in
  def each_fcgi_listener
    each_listener { |listener_port| yield listener_port }
  end

  def fcgi_listener_dirs
    listener_dirs
  end
  
  def handle_deprecated_vars
    handle_deprecated_var :fcgi_listener_base_port, :listener_base_port
    handle_deprecated_var :fcgi_count, :listener_count
  end
  
  def handle_deprecated_var(old_var, new_var)
    if @variables.has_key?(old_var)
      set new_var, @variables[old_var]
    end
    set old_var, @variables[new_var]
  end
end
