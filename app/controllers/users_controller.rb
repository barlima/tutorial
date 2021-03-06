class UsersController < ApplicationController

  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update, :show]
  before_action :admin_user,     only: :destroy


  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Account created successfully!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @points = @user.points
    @paths = @user.paths

    if @points.any?
      @points.each do |point|
        point.update_attribute(:user_id, 1)
      end
    end

    if @paths.any?
      @paths.each do |path|
        path.update_attribute(:user_id, 1)
      end
    end

    @user.destroy
    flash[:success] = "User deleted. All of the user paths and points have been moved to User with id: 1"
    redirect_to users_url
  end

  def creator
    @user = User.find(params[:id])
    if @user.update_attribute(:creator, !@user.creator)
      flash[:success] = 'User updated'
    else
      flash[:danger] = 'Cannot update selected user'
    end
    redirect_to users_path
  end

  def admin
    @user = User.find(params[:id])
    if @user.update_attribute(:admin, true)
      flash[:success] = 'User updated'
    else
      flash[:danger] = 'Cannot update selected user'
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Before filters

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

end
