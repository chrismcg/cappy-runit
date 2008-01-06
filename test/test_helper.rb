begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end
require 'test/unit'
$:.unshift File.dirname(__FILE__) + "/../lib", File.dirname(__FILE__)
require 'runit_helper'

module TestHelper
  class TestingConnectionFactory
    def initialize(config)
    end

    def connect_to(server)
      server
    end
  end

  class TestActor < Capistrano::Actor
    class TestTask
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
    end

    attr_reader :put_data, :run_data, :sudo_data
    
    def initialize(*args)
      super
      @current_task = nil
    end
    
    def run(cmd, options={}, &block)
      (@run_data ||= []) << cmd
    end

    def sudo(cmd, options={}, &block)
      (@sudo_data ||= []) << cmd
    end
  
    def put(data, path, options={})
      (@put_data ||= {})[path] = data
    end
    
    def metaclass
      class << self; self; end
    end
    
    def current_task
      @current_task || TestTask.new("")
    end
    
    def define_method(name, &block)
      metaclass.send(:define_method, name, &block)
    end
    
    def define_task(name, options={}, &block)
      @tasks[name] = (options[:task_class] || Task).new(name, self, options)
      define_method(name) do
        @current_task = TestTask.new(name)
        instance_eval(&block)
      end
    end    

    self.connection_factory = TestingConnectionFactory
    
    def reset!
      @put_data = {}
      @run_data = []
      @sudo_data = []
    end
  end

  class MockConfiguration
    attr_reader :actor
    
    def initialize(actor_class=TestActor)
      @variables = {}
      @actor = actor_class.new(self)
      instance_eval <<-TASKS
      task :run_task do
        runit_helper.run_or_sudo("run")
      end

      task :sudo_task do
        runit_helper.run_or_sudo("sudo")
      end
      TASKS
    end
    
    def set(variable, value = nil)
      @variables[variable] = value
    end
    
    def task(name, options={}, &block)
      actor.define_task(name, options, &block)
    end
    
    Role = Struct.new(:host, :options)

    ROLES = { 
      :db  => [ Role.new("01.example.com", :primary => true)],
      :web => [ Role.new("01.example.com", {})],
      :app => [ Role.new("01.example.com", {})]
    }

    def roles
      ROLES
    end
        
    def method_missing(sym, *args, &block)
      if @variables.has_key?(sym)
        @variables[sym]
      else
        super
      end
    end
  end
end