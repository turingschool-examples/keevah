class LoanRequest < ActiveRecord::Base
  validates :title, :description, :amount,
    :requested_by_date, :repayment_begin_date,
    :repayment_rate, :contributed, presence: true
  has_many :orders
  has_many :loan_requests_contributors
  has_many :users, through: :loan_requests_contributors
  has_many :loan_requests_categories
  has_many :categories, through: :loan_requests_categories
  belongs_to :user
  enum status: %w(active funded)
  enum repayment_rate: %w(monthly weekly)
  before_create :assign_default_image

  def assign_default_image
    self.image_url = DefaultImages.random if self.image_url.to_s.empty?
  end

  def owner
    self.user.name
  end

  def requested_by
    self.requested_by_date.strftime("%B %d, %Y")
  end

  def updated_formatted
    self.updated_at.strftime("%B %d, %Y")
  end

  def repayment_begin
    self.repayment_begin_date.strftime("%B %d, %Y")
  end

  def funding_remaining
    amount - contributed
  end

  def self.projects_with_contributions
    where("contributed > ?", 0)
  end

  def list_project_contributors
    project_contributors.map(&:name).to_sentence
  end

  def progress_percentage
    ((1.00 - (funding_remaining.to_f / amount.to_f)) * 100).to_i
  end

  def minimum_payment
    if repayment_rate == "weekly"
      (contributed - repayed) / 12
    else
      (contributed - repayed) / 3
    end
  end

  def repayment_due_date
    (repayment_begin_date + 12.weeks).strftime("%B %d, %Y")
  end

  def pay!(amount, borrower)
    repayment_percentage = (amount / contributed.to_f)
    project_contributors.each do |lender|
      repayment = lender.contributed_to(self).first.contribution * repayment_percentage
      lender.increment!(:purse, repayment)
      borrower.decrement!(:purse, repayment)
      self.increment!(:repayed, repayment)
    end
  end

  def remaining_payments
    (contributed - repayed) / minimum_payment
  end

  def project_contributors
    LoanRequestsContributor.where(loan_request_id: self.id).pluck(:user_id).map do |user_id|
      User.find(user_id)
    end
  end

  def related_projects
    cache_name = "related_projects-#{id}"
    if cache_empty?(cache_name)
      projects = LoanRequest.joins(:loan_requests_categories)
        .where(loan_requests_categories: {category_id: self.categories.sample.id})
        .limit(4)
        .order("RANDOM()")
      Rails.cache.write(cache_name, projects, expires_in: 60.minutes)

    end

    Rails.cache.fetch(cache_name)
  end

  def self.cache_count
    if Rails.cache.fetch('loan_requests_count').nil?
      Rails.cache.write('loan_requests_count', count)
    end
    Rails.cache.fetch('loan_requests_count')
  end

  private

  def cache_empty?(key)
    Rails.cache.fetch(key).nil?
  end
end
