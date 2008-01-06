begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

# This module provides methods to ease creating run scripts in service directories.
#
# The methods are available through runner.<method name> in your deploy.rb 
module RunitRunnerHelper
  # Creates a runner from a template, puts it on the server at the given
  # path and sets file permissions to 0700.
  #
  # * service_dir should be the path to your service directory, it should not 
  #   include run or log/run, these are added by create.
  # * template can be :log, :mongrel, :fcgi, the name of a file or a string.
  #   :log, :mongrel and :fcgi create the standard templates,
  #   see get_template below for a list of places searched for template files.
  # * If you're making a custom log runner, include :log_runner => true in the 
  #   options so create knows to put the contents in service_dir/log/run, you  
  #   don't need this if you're using the standard :log template.
  # * options except for :log_runner are assumed to be for the template and 
  #   are passed through to render. 
  def create(service_dir, template, options = {})
    case template
      when :log
        template = 'default_log_runner'
        options.merge!(:log_runner => true)
      when :fcgi
        template = 'default_fcgi_runner'
      when :mongrel
        template = 'default_mongrel_runner'
    end
    
    path = "#{service_dir}/#{options[:log_runner] ? 'log/run' : 'run'}" 
    options.delete(:log_runner)
    
    options = add_default_options(options)

    runner = render options.merge(:template => get_template(template))

    put runner, path, :mode => 0700    
  end  
  
  # Works out whether the given template is a file or string containing rhtml.
  # 
  # Checks:
  # * current directory
  # * runner_templates path (defaults to templates/runit)
  # * capistrano-runit-tasks-templates dir where cappy-runit is installed
  #   (the standard templates are here)
  # 
  # If it can't find the file it assumes it's a one line string template and 
  # returns that
  def get_template(template)
    if template =~ /<%/ or template =~ /\n/
      template
    else
      [ ".",
        configuration.runner_template_path,
        File.join(File.dirname(__FILE__), 'capistrano-runit-tasks-templates')
      ].each do |dir|
        if File.file?(File.join(dir, template))
          return File.read(File.join(dir, template))
        elsif File.file?(File.join(dir, template + ".rhtml"))
          @file_template_full_path = File.join(dir, template + ".rhtml")
          return File.read(File.join(dir, template + ".rhtml"))
        end
      end
    end
    template
  end
  
  protected
  def add_default_options(options)
    {:deploy_to => configuration.deploy_to}.merge(options)
  end
end

Capistrano.plugin :runner, RunitRunnerHelper