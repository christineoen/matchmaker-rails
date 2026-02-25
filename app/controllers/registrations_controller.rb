class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome, #{@user.first_name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user: [ :email_address, :password, :password_confirmation, :first_name, :last_name ])
  end
end
