load 'deploy'
load 'deploy/assets'

Dir['./lib/capistrano/*.rb'].each { |ext| require ext }
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy'
