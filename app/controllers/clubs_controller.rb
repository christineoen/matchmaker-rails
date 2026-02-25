class ClubsController < ApplicationController
  def index
    @clubs = Current.session.user.clubs
  end
end
