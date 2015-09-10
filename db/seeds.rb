require 'populator'
require 'faker'


class Seed
  def run
    create_known_users
    create_borrowers(10)
    create_lenders(100)
    create_loan_requests_for_each_borrower(20)
    create_categories
    create_orders
  end

  def lenders
    User.where(role: 0)
  end

  def borrowers
    User.where(role: 1)
  end

  def orders
    Order.all
  end

  def create_known_users
    User.create(name: "Jorge", email: "jorge@example.com", password: "password")
    User.create(name: "Rachel", email: "rachel@example.com", password: "password")
    User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
  end

  def create_lenders(quantity)
    quantity.times do
      name = Faker::Name.name
      email = Faker::Internet.email
      user = User.create(name: name,
                         password: "password",
                         email: email,
                         role: 0)
      puts "created lender #{user.name}"
    end
  end

  def create_borrowers(quantity)
    quantity.times do
      name = Faker::Name.name
      email = Faker::Internet.email
      user = User.create(name: name,
                         password: "password",
                         email: email,
                         role: 1)
      puts "created borrower #{user.name}"
    end
  end

  def create_categories
    ["agriculture", "community", "education"].each do |cat|
      Category.create(title: cat, description: cat + " stuff")
    end
    put_requests_in_categories
  end

  def put_requests_in_categories
    LoanRequest.all.shuffle.each do |request|
      Category.all.shuffle.first.loan_requests << request
      puts "linked request and category"
    end
  end

  def create_loan_requests_for_each_borrower(quantity)
    quantity.times do
      borrowers.each do |borrower|
        title = Faker::Commerce.product_name
        description = Faker::Company.catch_phrase
        status = [0, 1].sample
        request_by =
          Faker::Time.between(7.days.ago, 3.days.ago)
        repayment_begin_date =
          Faker::Time.between(3.days.ago, Time.now)
        amount = "200"
        contributed = "0"
        request = borrower.loan_requests.create(title: title,
                                                description: description,
                                                amount: amount,
                                                status: status,
                                                requested_by_date: request_by,
                                                contributed: contributed,
                                                repayment_rate: "weekly",
                                                repayment_begin_date: repayment_begin_date)
        puts "created loan request #{request.title} for #{borrower.name}"
        puts "There are now #{LoanRequest.count} requests"
      end
    end
  end

  def create_orders
    loan_requests = LoanRequest.all
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    loan_requests.each do |request|
      donate = possible_donations.sample
      lender = User.where(role: 0).order("RANDOM()").take(1).first
      order = Order.create(cart_items:
                           { "#{request.id}" => donate },
                           user_id: lender.id)
      order.update_contributed(lender)
      puts "Created Order for Request #{request.title} by Lender #{lender.name}"
    end
  end
end

class ProdSeed
  def run
    create_known_users
    create_borrowers(30000)
    create_lenders(200000)
    create_categories
    create_loan_requests_for_each_borrower(500000)
    create_orders(50000)
  end

  def lenders
    @lenders ||= User.where(role: 0)
  end

  def borrowers
    @borrowers ||= User.where(role: 1)
  end

  def orders
    Order.all
  end

  def create_known_users
    User.create(name: "Jorge", email: "jorge@example.com", password: "password")
    User.create(name: "Rachel", email: "rachel@example.com", password: "password")
    User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
  end

  def create_lenders(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.password_digest = "$2a$10$I3tkspOkQVkZrZHCLUInM.I/M1OvPRTH.2/YyPwb/MbfJ2mLbbUPG"
      user.role = 0
      puts "created lender #{user.name}"
    end
  end

  def create_borrowers(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.password_digest = "$2a$10$I3tkspOkQVkZrZHCLUInM.I/M1OvPRTH.2/YyPwb/MbfJ2mLbbUPG"
      user.role = 1
      puts "created borrower #{user.name}"
    end
  end

  def create_categories
    ["agriculture", "community", "education", "pizza", "food",
      "teaching", "school", "turing", "category", "hey",
      "one", "two", "three", "four", "five", "six", "seven"].each do |cat|
      Category.create(title: cat, description: cat + " stuff")
    end
  end

  def create_loan_requests_for_each_borrower(quantity)
    b = borrowers
    cats = Category.all
    LoanRequest.populate(quantity) do |lr|
      lr.title = Faker::Commerce.product_name
      lr.description = Faker::Company.catch_phrase
      lr.amount = 200
      lr.status = [0, 1].sample
      lr.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
      lr.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
      lr.repayment_rate = 1
      lr.contributed = 0
      lr.repayed = 0
      lr.user_id = b.sample.id
      LoanRequestsCategory.populate(2) do |lrcat|
        lrcat.loan_request_id = lr.id
        lrcat.category_id = cats.sample.id
      end
    end
  end

  def loan_request_ids
    @loan_requests ||= LoanRequest.pluck(:id)
  end

  def create_orders(num)
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    num.times do
      lender = lenders.sample
      request_id = loan_request_ids.sample
      order = Order.create(cart_items:
          { "#{request_id}" => possible_donations.sample },
        user_id: lender.id)
      order.update_contributed(lender)
      puts "Created Order by Lender #{lender.name}"
    end
  end
end




if Rails.env.production?
  ProdSeed.new.run
else
  Seed.new.run
end
