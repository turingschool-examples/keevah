require "load_script/session"

namespace :load_script do
  desc "Run a load testing script against the app. Accepts 'HOST' as an ENV argument. Defaults to 'localhost:3000'."
  task :run => :environment do
    if `which phantomjs`.empty?
      raise "PhantomJS not found. Make sure you have it installed. Try: 'brew install phantomjs'"
    end


    4.times.map do
      Thread.new do
        # if ARGV[1]
          Thread.new(LoadScript::Session.new(ARGV[1]).run)
        # else
        #   Thread.new( LoadScript::Session.new().run)
        # end
      end
    end.map(&:join)
  end
end

