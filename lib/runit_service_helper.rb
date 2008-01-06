begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

# This module provides an easy method to create service directories in your application and have them
# populated with runner scripts.
# 
# The methods are available through service.<method name> in your deploy.rb
module RunitServiceHelper
  # Adds a service to the applications service directory and creates run and log/run scripts
  # 
  # If no runner or logger options are passed, looks for a runner template called <service_name>_runner
  # and a log runner template called <service_name>_log_runner. These should be in the templates directory set
  # with runner_template_path in your deploy.rb.
  #
  # * If the runner template does not exist an exception will be raised
  # * If the logger template does not exist the standard logger template will be used.
  #
  # If you want to use your own template or a string containing rhtml pass a :template option to the appropriate
  # options hash. 
  #
  # The default options will be passed through to the template as described in RunitRunnerHelper#create
  def add(service_name, runner_options = {}, logger_options = {})
    make_service_dir service_name
    create_service(service_name, runner_options)
    create_service(service_name, logger_options.merge(:log_runner => true))
  end

  # Returns the full path to the service directory given a service name.
  # Doesn't check the service name is valid.
  def service_dir(service_name)
    "#{configuration.deploy_to}/#{configuration.service_dir}/#{service_name}"
  end
  
  protected
  def create_service(service_name, options)
    if options[:template].nil?
      runner_template_path = options[:log_runner] ? "#{service_name.to_s}_log_runner" : "#{service_name.to_s}_runner"        
      runner_template = runner.get_template(runner_template_path)
      if runner_template == runner_template_path # didn't find a template
        if options[:log_runner]
          # Just use the standard template
          runner_template = :log
        else
          raise "Couldn't find runner template #{runner_template_path} and no runner template provided"
        end
      end 
    else
      runner_template = options[:template]
    end
    options.delete(:template)
    runner.create service_dir(service_name), runner_template, options
  end

  def make_service_dir(service_name)
    runit_helper.run_or_sudo "mkdir -p #{service_dir(service_name)}/log/main"
  end
end

Capistrano.plugin :service, RunitServiceHelper  
