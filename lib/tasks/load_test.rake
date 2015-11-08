require 'capybara/poltergeist'

desc "Simulate load against scale up application"
task :load_test => :environment do
  4.times.map { Thread.new { browse } }.map(&:join)
end

def browse
  session = Capybara::Session.new(:poltergeist)
  100.times do
    session.visit("https://scale-up-time.herokuapp.com/")
    session.all("li.article a").sample.click
  end
end
