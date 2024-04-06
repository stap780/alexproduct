lock "~> 3.18.1"

server '95.163.236.170', roles: %w{app db web}

set :application, "alexproduct"
set :repo_url, "git@github.com:stap780/#{fetch(:application)}.git"


set :user, 'deploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0

set :branch, "main"
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

append :linked_files, "config/master.key", "config/database.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "public", 'tmp/sockets', 'vendor/bundle', 'lib/tasks', 'lib/drop', 'storage'

namespace :puma do
    desc 'Create Directories for Puma Pids and Socket'
    task :make_dirs do
      on roles(:app) do
        execute "mkdir #{shared_path}/tmp/sockets -p"
        execute "mkdir #{shared_path}/tmp/pids -p"
      end
    end
  
    before 'deploy:starting', 'puma:make_dirs'
end

namespace :sidekiq do
    desc "Overwritten sidekiq:{start, stop, restart}"
    task :restart do
      puts "Overwriting sidekiq:restart"
      on roles(:all) do |host|
        execute :systemctl, '--user','restart', 'sidekiq'
      end
    end
    task :start do
      puts "Overwriting sidekiq:start"
      on roles(:all) do |host|
        execute :systemctl, '--user','start', 'sidekiq'
      end
    end
    task :stop do
      puts "Overwriting sidekiq:stop"
      on roles(:all) do |host|
        execute :systemctl, '--user','stop', 'sidekiq'
      end
    end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      # Update this to your branch name: master, main, etc. Here it's master
      unless `git rev-parse HEAD` == `git rev-parse origin/main`
        puts "WARNING: HEAD is not the same as origin/main"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        invoke 'puma:restart'
      end
  end

#   namespace :sidekiq do  
#     desc 'Restart Sidekiq'
#     task :restart do
#       on roles(:app) do
#         execute :sudo, :systemctl, :restart, :sidekiq
#         execute :sudo, :systemctl, 'daemon-reload'
#       end
#     end
#   end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
#   after 'deploy:published', 'sidekiq:restart'
  
end
  
