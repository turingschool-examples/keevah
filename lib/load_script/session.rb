require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
      [
        :browse_loan_requests,
        :sign_up_as_lender,
        :sign_up_as_borrower,
        :user_browse_loans_requests,
        :new_borrower_create_loan_request,
        :lender_makes_loan,
        # :user_browses_categories,
        # :user_browses_category_pages
      ]
    end

    # Required User Paths

    ## Anonymous user browses loan requests
    ## User browses pages of loan requests
    # User browses categories
    # User browses pages of categories
    ## User views individual loan request
    ## New user signs up as lender
    ## New user signs up as borrower
    ### New borrower creates loan request
    ## Lender makes loan
    #
    def user_browses_categories

    end

    def user_browses_category_pages

    end

    def user_browse_loans_requests(email="jorge@example.com", pw="password")
      log_out
      log_in

      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def lender_makes_loan(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end

      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      session.click_link_or_button "Contribute $25"
    end

    def new_borrower_create_loan_request(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click

      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end

      session.click_link_or_button "Create Loan Request"

      session.within("#loanRequestModal") do
        session.fill_in("Title", with: title)
        session.fill_in("Description", with: description)
        session.fill_in("Requested by date", with: requested_by_date)
        session.fill_in("Repayment begin date", with: repayment_begin_date)
        session.select 'Agriculture', from: "loan_request_category"
        session.fill_in("Amount", with: amount)

        session.click_link_or_button "Submit"
      end
    end

    def title
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def description
      "#{Faker::Name.name} #{Time.now.to_i} description"
    end

    def requested_by_date
      "#{Faker::Date.forward(5)}"
    end

    def repayment_begin_date
      "#{Faker::Date.forward(15)}"
    end

    def amount
      1000
    end

    def log_in(email="josh@example.com", pw="password")
      log_out
      session.visit host
      session.click_link("Login")

      session.within("#loginModal") do
        session.fill_in("Email", with: email)
        session.fill_in("Password", with: pw)
        session.click_link_or_button("Log In")
      end
    end


    def browse_loan_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
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
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def categories
      ["Agriculture", "Education", "Community"]
    end
  end
end
