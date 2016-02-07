# config valid only for current version of Capistrano
lock '3.4.0'
set :default_env, { 'PATH' => '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH' }
# set :default_shell, '/bin/zsh --login'
set :application, 'railiner'
set :repo_url, 'git@github.com:airled/railiner'
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/railiner'
set :tmp_dir, '/home/railiner/tmp'
# Default value for :scm is :git
# set :scm, :git
# Default value for :format is :pretty
# set :format, :pretty
# Default value for :log_level is :debug
# set :log_level, :debug
# Default value for :pty is false
# set :pty, true
# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# Default value for keep_releases is 5
# set :keep_releases, 5
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.5'
# in case you want to set ruby version from the file:
# set :rbenv_ruby, File.read('.ruby-version').strip
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

namespace :app do

  task :start do
    on roles(:all) do
      within "#{fetch(:deploy_to)}/current/" do
        execute :bundle, :exec, :rake, 'local:start'
      end
    end
  end

  task :stop do
    on roles(:all) do
      within "#{fetch(:deploy_to)}/current/" do
        execute :bundle, :exec, :rake, 'local:stop'
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

end
