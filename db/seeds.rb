require "populator"

class Seed
  def run
    create_known_users
    create_categories
    create_borrowers(31000)
    create_lenders(201000)
    create_loan_requests_for_each_borrower(501000)
    create_orders(53000)
  end

  def lenders
    @lenders ||= User.where(role: 0)
  end

  def borrowers
    @borrowers ||= User.where(role: 1)
  end

  def orders
    @orders ||= Order.all
  end

  def loan_request_ids
    @loan_request_ids ||= LoanRequest.pluck(:id)
  end

  def create_known_users
    User.create(name: "Jorge", email: "jorge@example.com", password: "password")
    User.create(name: "Rachel", email: "rachel@example.com", password: "password")
    User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
  end

  def cats
    ["Agriculture",
     "Education",
     "Water and Sanitation",
     "Youth",
     "Conflict Zones",
     "Transportation",
     "Housing",
     "Banking and Finance",
     "Manufacturing",
     "Food and Nutrition",
     "Vulnerable Groups"]
  end

  def create_categories
    cats.each do |cat|
      Category.create(title: cat, description: cat + " stuff")
      puts "Created category #{cat}"
    end
  end

  def create_lenders(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      # do some email concatenation to ensure unique emails
      user.email = user.name.downcase.gsub(".","").split.join("-") + "-" + user.id.to_s + "@example.com"
      user.password_digest = "$2a$10$G3BpQrzzJAvyFlAqHUDAu.UlHwMGiswSsLRnhAS2DOmIhc7l1.ihK"
      user.role = 0
    end
  end

  def create_borrowers(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.password_digest = "$2a$10$G3BpQrzzJAvyFlAqHUDAu.UlHwMGiswSsLRnhAS2DOmIhc7l1.ihK"
      user.role = 1
    end
  end

  def create_loan_requests_for_each_borrower(quantity)
    brws = borrowers
    categories = Category.all

    LoanRequest.populate(quantity) do |lr|
      lr.title = Faker::Commerce.product_name
      lr.description = Faker::Company.catch_phrase
      lr.amount = 200
      lr.status = [0, 1].sample
      lr.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
      lr.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
      lr.repayment_rate = [0, 1].sample
      lr.contributed = 0
      lr.repayed = 0
      lr.user_id = brws.sample.id
      LoanRequestsCategory.populate(1) do |request_cat|
        request_cat.loan_request_id = lr.id
        request_cat.category_id = categories.sample.id
      end
    end
  end

  def create_orders(n)
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    n.times do
      donation = possible_donations.sample
      lender = lenders.sample
      request_id = loan_request_ids.sample
      order = Order.create(cart_items: { "#{request_id}" => donation },
                           user_id: lender.id)
      order.update_contributed(lender)
      puts "Created order ##{order.id}"
    end
  end
end

Seed.new.run
