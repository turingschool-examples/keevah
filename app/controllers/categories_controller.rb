class CategoriesController < ApplicationController
  def index
    @category = Category.all
  end

  def show
    @loan_requests ||= LoanRequest.joins(:loan_requests_categories)
      .where(loan_requests_categories: {category_id: params[:id] })
      .paginate(:page => params[:page], total_entries: 1200)
    # @loan_requests ||= LoanRequest.joins(:loan_requests_categories)
    #   .where(loan_requests_categories: {category_id: params[:id] })
    #   .paginate(:page => params[:page])
    @categories    = Category.all
  end
end
