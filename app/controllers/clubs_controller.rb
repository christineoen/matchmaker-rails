class ClubsController < ApplicationController
  before_action :set_club, only: :show

  def index
    @clubs = current_user.clubs
  end

  def show
  end

  def new
    @club = Club.new
  end

  def create
    @club = Club.new(club_params)

    unless @club.save
      render :new, status: :unprocessable_entity
      return
    end

    @club.memberships.create!(user: current_user, role: :admin)
    redirect_to @club, notice: "#{@club.name} created."
  end

  private

  def set_club
    @club = current_user.clubs.find(params[:id])
  end

  def club_params
    params.expect(club: [ :name ])
  end
end
