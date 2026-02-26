class PlayersController < ApplicationController
  include ClubScoped

  before_action :set_player, only: [ :edit, :update, :destroy ]

  def index
    @players = @club.players.order(:name)
    @player = Player.new(club: @club)
  end

  def new
    @player = Player.new(club: @club)
  end

  def create
    @player = Player.new(player_params.merge(club: @club))
    if @player.save
      redirect_to club_players_path(@club), notice: "#{@player.name} added."
    else
      @players = @club.players.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_back_or_to club_players_path(@club), notice: "#{@player.name} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to club_players_path(@club), notice: "Player removed."
  end

  def import
    file = params[:file]
    return redirect_to(club_players_path(@club), alert: "Please choose a CSV file.") if file.blank?

    result = ::CsvImport.players(@club, file)
    flash[:notice] = "#{result.imported} player(s) imported." if result.imported > 0
    flash[:alert] = result.errors.join("  ") if result.errors.any?
    redirect_to club_players_path(@club)
  rescue ArgumentError => e
    redirect_to club_players_path(@club), alert: e.message
  end

  private

  def set_player
    @player = @club.players.find(params[:id])
  end

  def player_params
    params.expect(player: [ :name, :gender, :grade_level_id, :grade_offset, :avoids_hard_courts ])
  end
end
