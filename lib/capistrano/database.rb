# Capistrano task to create the database.yml file.
#
# Just require 'lib/capistrano/database' in your Capistrano deploy.rb.

Capistrano::Configuration.instance(:must_exist).load do
  after "deploy:setup", "database:install"
  before "bundle:install", "database:symlink_config_file"

  namespace :database do
    desc <<-DESC
      Creates the config/database.yml, needed tables and users.

        set :database_username, "podmarker"
        set :database_name,     "podmarker"
    DESC
    task :install do
      require 'yaml'

      username = fetch(:database_username, 'podmarker')
      password = Capistrano::CLI.password_prompt("PostgreSQL application password: ")

      spec = {}
      create_commands = []
      fetch(:stages, %w(production)).each do |s|
        database = "#{fetch(:database_name, 'podmarker')}_#{s.to_s}"

        spec.merge! s.to_s => {
          "adapter"  => "postgresql",
          "encoding" => "unicode",
          "database" => database,
          "username" => username,
          "password" => password,
          "pool"     => 5,
          "host"     => "localhost"
        }

        create_commands << "createdb -U postgresql -O #{username} #{database}"
      end

      run "mkdir -p #{shared_path}/config"
      put(spec.to_yaml, "#{shared_path}/config/database.yml", :mode => 0644)

      create_commands.each do |command|
        run command
      end
    end

    desc <<-DESC
      Symlinks the config/database.yml file to current release.
    DESC
    task :symlink_config_file do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
end
