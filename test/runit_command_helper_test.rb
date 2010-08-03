require File.expand_path('../test_helper', __FILE__)

class RunitCommandHelperTest < Test::Unit::TestCase
  SIGNALS = %w(up down once pause cont hup alarm interrupt quit usr1 usr2 term kill)
  
  def setup
    @config = Capistrano::Configuration.new
    @config.set :runit_sudo_tasks, []
  end
  
  def test_should_load_runit_runner_helper
    assert Capistrano.const_get(:EXTENSIONS).keys.include?(:sv)    
  end
  
  def test_should_raise_error_if_sv_command_set_to_invalid_value
    @config.set :sv_command, :foo_bar
    assert_raises(RuntimeError) { @config.sv.down "foo" }
  end
  
  def test_should_generate_correct_commands_for_sv
    @config.set :sv_command, :sv

    SIGNALS.each_with_index do |signal, i|
      if signal =~ /usr([1|2])/
        @config.runit_helper.expects(:run_or_sudo).with("sv #{$1} foo")
      else
        @config.runit_helper.expects(:run_or_sudo).with("sv #{signal} foo")
      end
      @config.sv.send(signal, "foo")
    end
    
    @config.runit_helper.expects(:run_or_sudo).with("sv status foo")
    @config.sv.status "foo"
  end

  def test_should_generate_correct_commands_for_runsvctrl
    @config.set :sv_command, :runsvctrl

    SIGNALS.each_with_index do |signal, i|
      if signal =~ /usr([1|2])/
        @config.runit_helper.expects(:run_or_sudo).with("runsvctrl #{$1} foo")
      else
        @config.runit_helper.expects(:run_or_sudo).with("runsvctrl #{signal} foo")
      end
      @config.sv.send(signal, "foo")
    end
    
    @config.runit_helper.expects(:run_or_sudo).with("runsvstat foo")
    @config.sv.status "foo"
  end
  
  def test_should_accept_array_of_service_directions
    @config.set :sv_command, :sv
    @config.runit_helper.expects(:run_or_sudo).with("sv down foo bar")
    @config.sv.down %w(foo bar)
  end  
end
