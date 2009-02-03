require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")

CAPPY_RUNIT_VERSION = "0.2.3"

Hoe.new("capistrano-runit-tasks", CAPPY_RUNIT_VERSION) do |p|
  p.rubyforge_name = 'cappy-runit'
  p.author         = "Chris McGrath"
  p.changes        = p.paragraphs_of('History.txt', 1..3).join("\n")
  p.summary        = p.paragraphs_of('README.txt', 1)[0]
  p.description    = p.paragraphs_of('README.txt', 2)[0]
  p.email          = 'chris@octopod.info'
  p.url            = 'http://cappy-runit.rubyforge.org'
  p.test_globs     = ['test/*_test.rb']
end
# Gem::manage_gems
# 
# require 'rake/packagetask'
# require 'rake/gempackagetask'
# require 'rake/rdoctask'
# require 'rake/contrib/rubyforgepublisher'
# require 'rake/testtask'
# 
# PACKAGE_NAME = "capistrano-runit-tasks"
# PACKAGE_VERSION = "0.2.2"
# RELEASE_NAME  = "REL #{PACKAGE_VERSION}"
# PKG_FILE_NAME = "#{PACKAGE_NAME}-#{PACKAGE_VERSION}"
# RUBY_FORGE_PROJECT = "cappy-runit"
# RUBY_FORGE_USER = "octopod"
# 
# files = FileList["{lib}/**/*"].exclude("rdoc")
# 
# spec = Gem::Specification.new do |s| 
#   s.name = PACKAGE_NAME 
#   s.version = PACKAGE_VERSION
#   s.rubyforge_project = 'cappy-runit'
#   s.author = "Chris McGrath" 
#   s.email = "chris@octopod.info" 
#   s.files = files.dup
#   s.homepage = "http://cappy-runit.rubyforge.org" 
#   s.platform = Gem::Platform::RUBY 
#   s.summary = "Adds tasks to capistrano for use with the runit supervision scheme." 
#   s.require_path = "lib" 
#   s.autorequire = "capistrano-runit-tasks" 
#   s.has_rdoc = true 
#   s.extra_rdoc_files = ["README", "ChangeLog"] 
#   s.rdoc_options << '--title' << 'Capistrano runit tasks documentation' <<
#                     '--main'  << 'README'
#   s.add_dependency("capistrano", ">= 1.1.0") 
# end
#  
# Rake::GemPackageTask.new(spec) do |pkg| 
# end
# 
# Rake::PackageTask.new(PACKAGE_NAME, PACKAGE_VERSION) do |pkg|
#   pkg.package_files = files.dup << 'setup.rb'
#   pkg.need_tar_gz = true
#   pkg.need_zip = true
# end
# 
# Rake::RDocTask.new do |rd|
#   rd.main = "README"
#   rd.rdoc_files.include("README", 'ChangeLog', "lib/**/*.rb")
# end
# 
# desc "Publish the docs"
# task :publish_docs => :rdoc do
#   Rake::RubyForgePublisher.new(RUBY_FORGE_PROJECT, RUBY_FORGE_USER).upload
# end
# 
# desc "Run the tests"
# Rake::TestTask.new do |t|
#   t.test_files = FileList['test/*_test.rb']
#   t.verbose = true
# end
# 
# task :default => :test do
#   
# end
