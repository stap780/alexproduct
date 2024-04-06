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