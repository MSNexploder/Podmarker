# based on unicorn config from github. Can't be too bad ;-)
# http://github.com/blog/517-unicorn

rails_env = ENV['RAILS_ENV'] || 'production'

# 4 workers and 1 master
worker_processes (rails_env == 'production' ? 8 : 2)

# Load rails into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
if rails_env == 'production'
  listen '/home/web/applications/production/podmarker/shared/system/unicorn.sock', :backlog => 64
  working_directory '/home/web/applications/production/podmarker/current'
  stderr_path '/home/web/applications/production/podmarker/shared/log/unicorn.log'
  stdout_path '/home/web/applications/production/podmarker/shared/log/unicorn.log'
elsif rails_env == 'staging'
  listen '/home/web/applications/staging/podmarker/shared/system/unicorn.sock', :backlog => 16
  working_directory '/home/web/applications/staging/podmarker/current'
  stderr_path '/home/web/applications/staging/podmarker/shared/log/unicorn.log'
  stdout_path '/home/web/applications/staging/podmarker/shared/log/unicorn.log'
else
  listen 8888
end

before_fork do |server, worker|
  #
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = File.join(Rails.root, '/tmp/pids/unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  ActiveRecord::Base.establish_connection

  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to web:web

  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'web', 'web'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if %w(production staging).include? RAILS_ENV
      raise e
    else
      STDERR.puts "couldn't change user, oh well"
    end
  end
end
  