# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

task :parse => :environment do
  require './lib/parser'
  Parser.new.run
end

task :fill => :environment do
  require './lib/filler'
end

task :reparse => :environment do
  system('rake db:rollback STEP=8 && rake db:migrate && rake parse')
end

task :deploy do
  system('bundle exec cap production deploy')
end

task :sk do
  system('bundle exec sidekiq -c 1 -q railiner_costs')
end
