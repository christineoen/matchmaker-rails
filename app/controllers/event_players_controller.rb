class EventPlayersController < ApplicationController
  include ClubScoped

  before_action :set_event
  before_action :set_event_player, only: [ :update, :destroy ]

  def create
    player = @club.players.find(params[:player_id])
    @event_player = @event.event_players.create(player: player)
    redirect_to club_event_path(@club, @event)
  end

  def update
    @event_player.update(event_player_params)
    redirect_to club_event_path(@club, @event)
  end

  def destroy
    @event_player.destroy
    redirect_to club_event_path(@club, @event)
  end

  private

  def set_event
    @event = @club.events.find(params[:event_id])
  end

  def set_event_player
    @event_player = @event.event_players.find(params[:id])
  end

  def event_player_params
    params.expect(event_player: [ :sitting_out ])
  end
end
