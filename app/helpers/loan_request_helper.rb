module LoanRequestHelper

  def categories
    if cache_empty?('loan_requests_categories')
      categories = Category.all
      Rails.cache.write('loan_requests_categories', categories, expires_in: 60.minutes)

    end

    Rails.cache.fetch('loan_requests_categories')
  end

  private

  def cache_empty?(key)
    Rails.cache.fetch(key).nil?
  end
end
