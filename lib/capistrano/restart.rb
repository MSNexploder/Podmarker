# Auto restart task.
#
# Just require 'lib/capistrano/restart' in your Capistrano deploy.rb.

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    task :start, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_release} && bundle exec unicorn_rails -Dc #{current_release}/config/unicorn.rb -E #{stage}"
    end
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "kill -QUIT `cat #{current_release}/tmp/pids/unicorn.pid`"
    end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "kill -USR2 `cat #{current_release}/tmp/pids/unicorn.pid`"
    end
  end
end
