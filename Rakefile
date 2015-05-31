# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
Rails.application.load_tasks

task :parse => :environment do
  require './lib/parser'
  Parser.instance.run
end

task :work => :environment do
  require './lib/worker'
  url = 'http://catalog.onliner.by/mobile/'
  Worker.new.find_category_db(url)
end