lock '3.4.0'
set :default_env, { 'PATH' => '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH' }
set :application, 'railiner'
set :repo_url, 'git@github.com:airled/railiner'
set :deploy_to, '/home/railiner'
set :tmp_dir, '/home/railiner/tmp'
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :rbenv_type, :user
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

# task :start do
#   on roles(:all) do
#     within "#{fetch(:deploy_to)}/current/" do
#       execute 'source ~/.zshrc && cd current && bundle exec unicorn -c config/unicorn.rb -E production -D && echo "Unicorn started"'
#     end
#   end
# end

# task :stop do
#   on roles(:all) do
#     within "#{fetch(:deploy_to)}/current/" do
#       execute "pid=$(cat #{fetch(:deploy_to)}/current/tmp/pids/unicorn.pid) && kill -9 $(echo $pid) && echo 'Unicorn killed'"
#     end
#   end
# end

task :start do
  on roles(:all) do
    within "#{fetch(:deploy_to)}/current/" do
      execute 'source ~/.zshrc && cd current && bundle exec thin -C config/thin.yml -R config.ru start && echo "Started"'
    end
  end
end

task :stop do
  on roles(:all) do
    within "#{fetch(:deploy_to)}/current/" do
      execute "source ~/.zshrc && cd current && bundle exec thin stop && echo 'Stopped'"
    end
  end
end

task :reparse do
  on roles(:all) do
    within "#{fetch(:deploy_to)}/current/" do
      execute :bundle, :exec, :rake, 'reset RAILS_ENV=production'
      execute 'source ~/.zshrc && cd current && RAILS_ENV=production bundle exec rake parse\[d\]'
    end
  end
end
