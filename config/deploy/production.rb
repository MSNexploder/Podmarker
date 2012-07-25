set :deploy_to, "/home/web/applications/production/podmarker"
set :rails_env, "production"

role :web, "podmarker.org"                          # Your HTTP server, Apache/etc
role :app, "podmarker.org"                          # This may be the same as your `Web` server
role :db,  "podmarker.org", :primary => true        # This is where Rails migrations will run

set :user, "web"
set :use_sudo, false
