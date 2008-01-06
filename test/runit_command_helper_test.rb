require 'test_helper'

class RunitCommandHelperTest < Test::Unit::TestCase
  include TestHelper
  
  SIGNALS = %w(up down once pause cont hup alarm interrupt quit usr1 usr2 term kill)
  
  def setup
    @actor = TestActor.new(MockConfiguration.new)    
    @actor.configuration.set :runit_sudo_tasks, []
  end
  
  def test_should_load_runit_runner_helper
    assert Capistrano.const_get(:EXTENSIONS).include?(:sv)    
  end
  
  def test_should_raise_error_if_sv_command_set_to_invalid_value
    @actor.configuration.set :sv_command, :foo_bar
    assert_raises(RuntimeError) { @actor.sv.down "foo" }
  end
  
  def test_should_generate_correct_commands_for_sv
    @actor.configuration.set :sv_command, :sv

    SIGNALS.each_with_index do |signal, i|
      @actor.sv.send(signal, "foo")
      if signal =~ /usr([1|2])/
        assert_equal "sv #{$1} foo", @actor.run_data[i]
      else
        assert_equal "sv #{signal} foo", @actor.run_data[i]
      end
    end
    
    @actor.reset!
    @actor.sv.status "foo"
    assert_equal "sv status foo", @actor.run_data[0]
  end

  def test_should_generate_correct_commands_for_runsvctrl
    @actor.configuration.set :sv_command, :runsvctrl

    SIGNALS.each_with_index do |signal, i|
      @actor.sv.send(signal, "foo")
      if signal =~ /usr([1|2])/
        assert_equal "runsvctrl #{$1} foo", @actor.run_data[i]
      else
        assert_equal "runsvctrl #{signal} foo", @actor.run_data[i]
      end
    end

    @actor.reset!
    @actor.sv.status "foo"
    assert_equal "runsvstat foo", @actor.run_data[0]
  end
  
  def test_should_accept_array_of_service_directions
    @actor.configuration.set :sv_command, :sv
    @actor.sv.down %w(foo bar)
    assert_equal "sv down foo bar", @actor.run_data[0]
  end  
end