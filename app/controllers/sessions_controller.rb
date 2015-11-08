class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      if @user.admin?
        session[:user_id] = @user.id
        flash[:notice] = "Welcome to Keevahh, #{@user.name}!"
        redirect_to admin_path(@user)
      elsif @user.lender?
        session[:user_id] = @user.id
        flash[:notice] = "Welcome to Keevahh, #{@user.name}!"
        redirect_to(:back)
      elsif @user.borrower?
        session[:user_id] = @user.id
        flash[:notice] = "Welcome to Keevahh, #{@user.name}!"
        redirect_to borrower_path(@user)
      end
    else
      flash[:notice] = "Invalid Login"
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "See you next time!"
    redirect_to root_path
  end
end
