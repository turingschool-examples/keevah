class CategoriesController < ApplicationController
  def index
    @category = categories
  end

  def show
    @loan_requests = LoanRequest.joins(:loan_requests_categories)
      .where(loan_requests_categories: {category_id: params[:id] })
      .paginate(page: params[:page],
                per_page: 9,
                total_entries: LoanRequest.cache_count)
    @categories    = categories
  end

  private

  def categories
    if cache_empty?('loan_requests_categories')
      Rails.cache.write('loan_requests_categories', Category.all, expires_in: 60.minutes)
    end

    Rails.cache.fetch('loan_requests_categories')
  end


  def cache_empty?(key)
    Rails.cache.fetch(key).nil?
  end
end
