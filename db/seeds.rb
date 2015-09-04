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

  def random_picture
    %w(http://www.kiva.org/img/w632/1847429.jpg http://www.kiva.org/img/w800/1854916.jpg http://www.kiva.org/img/w800/1848510.jpg https://envs1324nateaddie.files.wordpress.com/2011/04/farmer.jpg http://thirdworldfarming.org/wp-content/uploads/2013/08/TWF-india.jpg http://www.sej.org/sites/default/files/webform/AwardsWinners2012/MM7753_20101103_47348.jpg http://news.bbc.co.uk/olmedia/755000/images/_758899_farmer.jpg http://www.globalresearch.ca/wp-content/uploads/2010/05/119229.jpg http://i.telegraph.co.uk/multimedia/archive/02418/cattle-farming-col_2418406b.jpg http://futurefood2050.com/wp-content/uploads/cassava-farmers-AGRA.jpg http://econews.com.au/wp-content/uploads/2012/11/CIFOR-women-farmers.jpg http://cdn.fairfaxregional.com.au/silverstone-feed-data/63b592ab-b0da-4926-9e47-cfc9bec6fe87.jpg http://www.manchestergossip.com/sites/default/files/field/image/fair-face.jpg https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTDQZ_-xuwRzIhqO1FaabfDDnuQeXSOxfh0yZ6Zw8ZrBRyCX3eY).sample
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
        picture_url = random_picture
        request = borrower.loan_requests.create(title: title,
                                                description: description,
                                                amount: amount,
                                                status: status,
                                                requested_by_date: request_by,
                                                contributed: contributed,
                                                image_url: picture_url,
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

Seed.new.run
