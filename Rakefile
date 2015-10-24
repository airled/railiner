# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

desc "Parses Onliner's product pages and fills database's tables with main information. Use 'd'-argument for running the parser as daemon like ' rake parse[d] '. Notice: If you use Zsh, you should run parser as daemon like ' rake parse\[d\] ' or ' rake 'parse[d]' '."
task :parse, [:arg] do |t, arg|
  Rake::Task['environment'].invoke
  require './lib/parser'
  as_daemon = false
  if arg[:arg] == 'd'
    as_daemon = true
    puts "WARNING: Argument 'd' found. Starting parse as daemon"
  end
  Parser.new.run(as_daemon)
end

desc 'Resets the migrations.'
task :reset do
  system('rake db:rollback STEP=8 && rake db:migrate')
end

desc 'Starts to parse right after resetting the migrations.'
task :reparse => [:environment, :reset, :parse] do
end

desc "Runs special script for filling database table with sellers. Use it only after 'Costs'-table is finished to fill."
task :fill => :environment do
  require './lib/sellers_filler'
  Filler.run
end
desc 'Stops application on the server, deploies from Github and starts it again.'
task :deploy do
  Rake::Task['remote:stop'].invoke
  system('bundle exec cap production deploy')
  Rake::Task['remote:start'].invoke
end

desc "Starts Sidekiq process to fill 'Costs'-table with prices."
task :sk do
  system('bundle exec sidekiq -C config/sidekiq.yml -d')
end

desc 'Kills Sidekiq process'
task :skk do
  pid = File.open('./tmp/pids/sidekiq.pid') { |f| f.read }
  system("kill #{pid.strip}")
  puts 'Sidekiq killed.'
end

namespace :local do

  desc "Starts application locally with Unicorn server."
  task :start do
    system('source ~/.zshrc && bundle exec unicorn -c config/unicorn.rb -E production -D')
    puts 'Unicorn started.'
  end

  desc "Stops application runned with Unicorn."
  task :stop do
    pid = File.open('/home/onliner/current/tmp/pids/unicorn.pid') { |f| f.read }
    system("kill #{pid.strip}")
    puts 'Unicorn killed.'
  end

end

namespace :remote do

  desc 'Starts remote application with Capistrano.'
  task :start do
    system('bundle exec cap production app:start')
  end

  desc 'Stops remote application with Capistrano.'
  task :stop do
    system('bundle exec cap production app:stop')
  end  

  desc 'Starts reparsing remotely with Capistrano.'
  task :reparse do
    system('bundle exec cap production app:reparse')
  end

end
