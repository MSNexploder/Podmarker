require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :application, "Podmarker"
set :repository,  "https://github.com/MSNexploder/Podmarker.git"
set :deploy_to, "/home/web/applications/podmarker"

set :stages, %w(staging production)
set :default_stage, "staging"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "podmarker.org"                          # Your HTTP server, Apache/etc
role :app, "podmarker.org"                          # This may be the same as your `Web` server
role :db,  "podmarker.org", :primary => true        # This is where Rails migrations will run

set :user, "web"
set :use_sudo, false

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end