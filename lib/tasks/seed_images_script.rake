desc "Add images for seeded loan request records"
task :update_images => :environment do

  LoanRequest.find_each do |loan_request|
    image = DefaultImages.random
    loan_request.update_attributes(image_url: image)
  end
end
