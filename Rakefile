# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

task :parse => :environment do
  require './lib/parser'
  Parser.new.run
end

task :reparse => :environment do
  system('rake reset && rake parse')
end

task :fill => :environment do
  require './lib/sellers_filler'
  Filler.run
end

task :deploy do
  system('bundle exec cap production deploy')
end

task :reset do
  system('rake db:rollback STEP=8 && rake db:migrate')
end

task :sk do
  system('bundle exec sidekiq -C config/sidekiq.yml -d')
end

task :skk do
  pid = File.open('./tmp/pids/sidekiq.pid') { |f| f.read }
  system("kill #{pid.strip}")
  puts 'Sidekiq killed.'
end

namespace :local do

  task :start do
    system('bundle exec unicorn -c config/unicorn.rb -E production -D')
    puts 'Unicorn started.'
  end

  task :stop do
    pid = File.open('/home/onliner/current/tmp/pids/unicorn.pid') { |f| f.read }
    system("kill #{pid.strip}")
    puts 'Unicorn killed.'
  end

end

namespace :rem do

  task :start do
    system('bundle exec cap production app:start')
  end

  task :stop do
    system('bundle exec cap production app:stop')
  end

end