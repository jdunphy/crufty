namespace :crufty do
  desc "Run with DIR='something' to check methods just within that location"
  task :find_methods do
    if ENV['DIR']
      require File.dirname(__FILE__) + '/../lib/crufty'
      Crufty.find_methods(ENV['DIR'], ENV['SENSITIVITY'])
    else
      puts "DIR=<location> is required"
    end
  end
end