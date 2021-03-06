# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

desc "Parse Onliner's product pages and fill database's tables, use the d-argument for running as a daemon and the q-argument for a sidekiq queue filling"
task :parse, [:arg1, :arg2] do |t, args|
  Rake::Task['environment'].invoke
  require './lib/parser'
  as_daemon =
    if Hash[args].has_value?('d')
      puts "WARNING: Argument 'd' found. Running parser as daemon"
      true
    end || false
  with_queue =
    if Hash[args].has_value?('q')
      puts "WARNING: Argument 'q' found. Running parser with queue filling"
      true
    end || false
  Parser.new(as_daemon, with_queue).run
end

desc 'Reset the migrations.'
task :reset do
  system('rake db:rollback STEP=8 && rake db:migrate')
end

desc 'Start to parse right after resetting the migrations.'
task reparse: [:environment, :reset, :parse] do
end

desc "Run special script for filling 'Sellers'-table. Use it only if 'Costs'-table has been filled."
task fill: :environment do
  require './lib/sellers_filler'
  Filler.run
end

desc 'Stop the application on the server, deploy from Github and start it again.'
task :deploy do
  Rake::Task['remote:stop'].invoke
  system('bundle exec cap production deploy')
  Rake::Task['remote:start'].invoke
end

desc "Start the sidekiq process to fill 'Costs'-table."
task :sk do
  system('bundle exec sidekiq -C config/sidekiq.yml -d')
end

desc 'Kill the sidekiq process.'
task :skk do
  pid = File.open('./tmp/pids/sidekiq.pid') { |f| f.read }
  system("kill #{pid.strip}")
  puts 'Sidekiq killed.'
end

namespace :remote do

  desc 'Start the remote application with Capistrano.'
  task :start do
    system('bundle exec cap production start')
  end

  desc 'Stop the remote application with Capistrano.'
  task :stop do
    system('bundle exec cap production stop')
  end  

  desc 'Start reparsing remotely with Capistrano.'
  task :reparse do
    system('bundle exec cap production reparse')
  end

end
