begin
  require 'capistrano'
rescue LoadError
  require 'rubygems'
  require 'capistrano'
end

# This module provides a facade to allow signals to be set to runit managed
# service directories from Capistrano. It uses the <tt>sv_command</tt> variable to decide
# which command to run on the server and currently supports both <tt>sv</tt> and <tt>runsvctrl</tt>.
#
# The <tt>:sv_command</tt> variable can be set to <tt>:sv</tt> or <tt>:runsvctrl</tt> to choose.
#
# The supported signals are shown in the <tt>SIGNALS</tt> constant below.
#
# Usage examples:
# * <tt>sv.usr2 "/path/to/service/dir"</tt>
# * <tt>sv.down ["foo1", "foo2"]</tt>
#
# As daemontools is very similar, support for that will be added at a later date.
#
# The methods are available through sv.<method name> in your deploy.rb
module RunitCommandHelper
  SIGNALS = %w(up down once pause cont hup alarm interrupt quit usr1 usr2 term kill status) unless defined? SIGNALS

  SIGNALS.each do |signal|
    if signal =~ /usr([1|2])/ then
      cmd = $1
    else
      cmd = signal
    end

    define_method(signal) do |service_dirs|
      service_dirs = service_dirs.join(" ") if service_dirs.is_a? Array
      runit_helper.run_or_sudo "#{get_command(signal, cmd)} #{service_dirs}"
    end
  end

  protected
  def get_command(signal, cmd)
    case self.sv_command
      when :sv
        "sv #{cmd}"
      when :runsvctrl
        signal == 'status' ? 'runsvstat' : "runsvctrl #{cmd}"
      else
        raise "Error: sv_command setting of #{self.sv_command} is unsupported"
    end
  end  
end

Capistrano.plugin :sv, RunitCommandHelper