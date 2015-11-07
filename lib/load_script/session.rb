require "logger"
require "pry"
require "capybara"
require "capybara/poltergeist"
require "faker"
require "active_support"
require "active_support/core_ext"
require "benchmark"

Capybara.default_driver = :poltergeist

module LoadScript
  class Session
    ACTIONS = [:browse_loan_requests, :sign_up_as_lender, :sign_up_as_borrower]

    def self.run(host)
      ACTIONS.each do |action|
        threads = []
        benchmarked_times = []
        4.times do
          threads << Thread.new do
            difference = Benchmark.realtime do
              session = new(action)
              session.run
            end
            benchmarked_times << difference
          end
        end
        threads.each do |thread|
          thread.join
        end
        average_time = benchmarked_times.reduce(:+) / benchmarked_times.size
        logger.info "#{action} finished in an average of #{average_time} seconds"
      end
    end

    def self.logger
      @logger ||= Logger.new("./log/requests.log")
    end

    include Capybara::DSL

    attr_reader :host

    def initialize(action, host: "http://localhost:3000")
      @action = action
      @host = host
    end

    def logger
      self.class.logger
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      puts "Running #{@action}..."
      send(@action)
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{@action}. Will continue.")
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_link("Log In")
      session.fill_in("email_address", with: email)
      session.fill_in("password", with: pw)
      session.click_link_or_button("Login")
    end

    def browse_loan_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.click_on("Log out")
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.click_on("Sign Up As Lender")
      session.fill_in("Name", with: name)
      session.fill_in("Email", with: new_user_email(name))
      session.fill_in("Password", with: "password")
      session.fill_in("Confirm Password", with: "password")
      session.click_on "Create Account"
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.click_on("Sign Up As Borrower")
      # session.within("#borrowerSignUpModal") do
      session.fill_in("Name", with: name)
      session.fill_in("Email", with: new_user_email(name))
      session.fill_in("Password", with: "password")
      session.fill_in("Confirm Password", with: "password")
      session.click_on "Create Account"
      # end
    end

    def categories
      ["Agriculture", "Education", "Housing"]
    end
  end
end
