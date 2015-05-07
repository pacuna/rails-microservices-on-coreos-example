class UsersController < ApplicationController
  respond_to :json
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def create
    @user = User.new(name: params[:name], email: params[:email])

    if @user.save
      respond_with @user
    end
  end

  def comments
    @user = User.find(params[:id])
    respond_with @user.comments
  end
end
