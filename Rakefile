require 'rubygems'
require 'rake/testtask'

desc "Run the tests"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :default => :test
