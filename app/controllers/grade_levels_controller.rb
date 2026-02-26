class GradeLevelsController < ApplicationController
  include ClubScoped

  before_action :set_grade_level, only: [ :edit, :update, :destroy ]

  def index
    @grade_levels = @club.grade_levels.ordered
    @grade_level = GradeLevel.new(club: @club)
  end

  def new
    @grade_level = GradeLevel.new(club: @club)
  end

  def create
    @grade_level = GradeLevel.new(grade_level_params.merge(club: @club))
    if @grade_level.save
      redirect_to club_grade_levels_path(@club), notice: "Grade level added."
    else
      @grade_levels = @club.grade_levels.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @grade_level.update(grade_level_params)
      redirect_to club_grade_levels_path(@club), notice: "Grade level updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @grade_level.destroy
    redirect_to club_grade_levels_path(@club), notice: "Grade level removed."
  end

  def import
    file = params[:file]
    return redirect_to(club_grade_levels_path(@club), alert: "Please choose a CSV file.") if file.blank?

    result = ::CsvImport.grade_levels(@club, file)
    flash[:notice] = "#{result.imported} grade level(s) imported." if result.imported > 0
    flash[:alert] = result.errors.join("  ") if result.errors.any?
    redirect_to club_grade_levels_path(@club)
  rescue ArgumentError => e
    redirect_to club_grade_levels_path(@club), alert: e.message
  end

  private

  def set_grade_level
    @grade_level = @club.grade_levels.find(params[:id])
  end

  def grade_level_params
    params.expect(grade_level: [ :name, :rank ])
  end
end
