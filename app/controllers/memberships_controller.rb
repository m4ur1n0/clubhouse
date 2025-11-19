class MembershipsController < ApplicationController
    before_action :require_user!
    before_action :set_club

    def create
        current_user.memberships.find_or_create_by!(club: @club)
        redirect_to club_path(@club), notice: "You have joined the club!"
    end

    def destroy
        current_user.memberships.where(club: @club).destroy_all
        redirect_to club_path(@club), notice: "You have left the club."
    end

    private

    def set_club
        @club = Club.find(params[:club_id])
    end
end
