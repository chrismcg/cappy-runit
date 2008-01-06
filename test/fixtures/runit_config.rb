require File.dirname(__FILE__) + '/../../lib/capistrano-runit-tasks'

set :application, "foo"
role :web, "www.example.com", :primary => true
role :app, "www.example.com", :primary => true

task :setup do
  
end