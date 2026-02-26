class CourtsController < ApplicationController
  include ClubScoped

  before_action :set_court, only: [ :edit, :update, :destroy ]

  def index
    @courts = @club.courts.order(:created_at)
    @court = Court.new(club: @club)
  end

  def new
    @court = Court.new(club: @club)
  end

  def create
    @court = Court.new(court_params.merge(club: @club))
    if @court.save
      redirect_to club_courts_path(@club), notice: "Court added."
    else
      @courts = @club.courts
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @court.update(court_params)
      redirect_to club_courts_path(@club), notice: "Court updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @court.destroy
    redirect_to club_courts_path(@club), notice: "Court removed."
  end

  def import
    file = params[:file]
    return redirect_to(club_courts_path(@club), alert: "Please choose a CSV file.") if file.blank?

    result = ::CsvImport.courts(@club, file)
    flash[:notice] = "#{result.imported} court(s) imported." if result.imported > 0
    flash[:alert] = result.errors.join("  ") if result.errors.any?
    redirect_to club_courts_path(@club)
  rescue ArgumentError => e
    redirect_to club_courts_path(@club), alert: e.message
  end

  private

  def set_court
    @court = @club.courts.find(params[:id])
  end

  def court_params
    params.expect(court: [ :name, :surface ])
  end
end
