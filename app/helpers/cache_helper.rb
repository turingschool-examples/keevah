module CacheHelper

  def related_projects(loan_request)
    if cache_empty?('related_projects')
      # projects = LoanRequest.joins(:loan_requests_categories)
      projects = loan_request.joins(:loan_requests_categories)
        .where(loan_requests_categories: {category_id: self.categories.sample.id})
        .limit(4)
        .order("RANDOM()")
      Rails.cache.write('related_projects', projects, expires_in: 10.minutes)
    end

    Rails.cache.fetch('related_projects')
  end

  private

  def cache_empty?(key)
    Rails.cache.fetch(key).nil?
  end
end
