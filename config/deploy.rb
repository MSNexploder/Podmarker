require 'bundler/capistrano'

set :stages, %w(staging production)
set :default_stage, "staging"

require 'capistrano/ext/multistage'

set :application, "Podmarker"

set :repository,  "https://github.com/MSNexploder/Podmarker.git"
set :scm, :git
