= Capistrano runit tasks

Adds tasks to Capistrano for use with the runit supervision scheme.

This library extends Capistrano to allow processes to be supervised using the
runit package. It replaces some of the standard tasks with runit versions and
includes tasks and helpers to create the service directory layout and populate
it with run scripts. It has support fcgi, mongrel and merb listeners, and tries to
make it easy to add other services in your deploy.rb.

== Status

capistrano-runit-tests 0.3.0 (known as cappy-runit from now on) is the third
release of the library. It supports both the sv and runsvctrl/runsvstat versions of runit.

== Quick Start

This assumes you're creating a fresh install, not migrating an app from
spinner/spawner/reaper.

Install the package via gems or .tgz / .zip and setup.rb.

Include it in your deploy.rb with: 

require "capistrano-runit-tasks"

Then run:

* cap setup
* cap cold_deploy

This sets up one mongrel listener on port 8000. Make sure your database is
setup and point your webserver at the new listener.

== Usage

When you require "capistrano-runit-tasks" it replaces the following cap tasks
with runit versions:

* cold_deploy
* restart
* spinner
	
Then adds the following tasks, helpers and variables:

=== Tasks

[setup_service_dirs] Creates the skeleton directory structure for the services

[after_setup]        Calls setup_service_dirs so they're created as part of
                     the standard cap setup

=== Variables

[service_dir]             Change this if you want to change the name
                          of the service directory in the app on the server(s).
                          (Default: service)

[service_root]            Change this if you want to change the location
                          of the service directory.
                          (Default: Same as your deploy_to)

[master_service_dir]      Supervised directory where cappy-runit will link the
                          service directories to to start the service.
                          (Default: ~/services)

[listener_count]          Number of listener service dirs to create.
                          (Default: 1) (old name: fcgi_count)

[listener_base_port]      The base port number to use for the listeners.
                          (Default: 9000) (old name: fcgi_listener_base_port)

[sv_command]               Either :sv or :runsvctrl
                           (Default: sv)
                           
[runner_template_path]     The path to search for custom templates.
                           (Default: templates/runit)
                           
[runit_sudo_tasks]         Array of tasks names to run using sudo
                           (default: [])

cappy-runit creates a service directory for each listener you ask for. 

The directories are named after the port number the listener will run on. If
you specified 8500 for the base port and 3 for the listener_count then
service/8500, service/8501 and service/8502 directories will be created and
populated with run scripts that launch the listeners on the corresponding
port.

When the service directories are linked into the master service dir to run,
they are named <application>-<port number>. So if :application is set to "foo"
in deploy.rb you'll get foo-8500, foo-8501 etc.

=== Sudo

When a runit task executes, it will check to see if it's name is included in
the runit_sudo_tasks array. If so, it will use sudo rather than run when
executing its commands. Note, only tasks defined within capistrano-runit-tasks
will do this, none of the standard tasks are changed.

=== Helpers

[each_listener]      Uses the values for listener_base_port and listener_count
                     to yield each of the listener port numbers back to the
                     calling block

[listener_dirs]      Returns an array containing the path to each of the 
                     listener dirs. This is useful when sending commands using
                     sv as it accepts an array of directories as an argument
                     
[service.add]        Adds a new service to the application, see the
                     documentation in RunitServiceHelper for more
                     
[sv.<signal>]        Sends the signal given to services you choose. See the 
                     documentation in RunitCommandHelper for more details.

[runner.create]      Creates runner scripts, see the documentation in
                     RunitRunnerHelper method for how it's used.

== Logging

The default tasks create a log directory under each service directory. You can
override the default log template as described below if you need something
different.

== Overriding the default templates

The directory pointed to by the runner_template_path variable is searched
before the directory containing the default templates. If you want to override
the default templates, create default_mongrel_runner.rhtml or
default_fcgi_runner.rhtml and/or default_log_runner.rhtml and cappy-runit will
pick your custom versions first.

== Adding your own services

The example below assumes you are creating a service called mailer.

To add your own service directories and run scripts, add a template to
templates/runit called mailer_runner with contents:

 #!/bin/sh -e
 export RAILS_ENV=production
 exec 2>&1  /usr/bin/env ruby <%= application_dir %>/current/script/mailer

Then, in your deploy.rb create after_setup_service_dirs, after_spinner and
after_restart tasks that look something like these:

 task :after_setup_service_dirs do
   service.add 'mailer'
 end

 task :after_spinner do
   mailer_service_dir = "#{deploy_to}/#{service_dir}/mailer"
   run "ln -sf #{mailer_service_dir} #{master_service_dir}/#{application}-mailer"
 end

 task :after_restart do
   mailer_service_dir = "#{deploy_to}/#{service_dir}/mailer"
   run "runsvctrl down #{mailer_service_dir}"
   run "runsvctrl up #{mailer_service_dir}"
 end

So the process is:

* create the runner template (and logger if you need, see docs)
* add the service
* add a spinner task to get runit to start supervising
* add the tasks to stop and start as needed

== Switching from spinner/spawner/reaper

This again should be automated, the manual steps I used were:

* Modify deploy.rb and do a test deploy to a new directory on a different port
* Check the deploy worked ok
* Revert deploy.rb
* cap setup_service_dirs to create the structure (Won't touch what's running)
* Kill the spinner process
* use script/process/reaper to kill the running listeners
* cap cold_deploy to start the service
* Check everything is running OK

== TODO

* Allow add_service to create more than one directory to be supervised 
* Add task to automate switching from spinner
* Make which servers the code runs on configurable
* Allow creation of other files such as log/config
* Add support for daemontools svc command
* Make the RAILS_ENV configurable
* Add helper methods to make linking the services into the master service
  directory easier