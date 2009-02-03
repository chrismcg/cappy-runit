begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

# This module provides a run_or_sudo helper method that checks what is should
# use before running a command
module RunitHelper
  def run_or_sudo(command)
    if self.current_task && self.runit_sudo_tasks.include?(self.current_task.name)
      try_sudo command
    else
      run command
    end
  end
  
  private
  def find_caller
    Kernel.caller.each do |caller_details|
      if caller_details =~ /`(.*?)'$/
        unless $1.nil? || %(run_or_sudo instance_eval initialize).include?($1)
          break $1.intern
        end
      end
      next
    end
  end
end

Capistrano.plugin :runit_helper, RunitHelper
