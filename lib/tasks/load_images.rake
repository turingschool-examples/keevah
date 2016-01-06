namespace :load_images do
  desc "Add images to Loan Request Objects"
  task :run => :environment do

    LoanRequest.find_each do |loan_request|
      image = DefaultImages.random
      loan_request.update_attributes(image_url: image)
      puts "Adding image to loan request ##{loan_request.id}"
    end
  end
end
