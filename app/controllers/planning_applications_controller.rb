# frozen_string_literal: true

class PlanningApplicationsController < ApplicationController
  before_action :set_planning_application, only: [:show, :show_uid, :geometry]
  respond_to :js, only: [:hide, :unhide]

  def show
  end

  def geometry
    if @planning_application.location
      respond_to do |format|
        format.json { render json: RGeo::GeoJSON.encode(planning_application_feature(@planning_application)) }
      end
    else
      head :no_content
    end
  end

  def search
    @query = params[:q].strip
    planning_applications = PlanningApplication.where("uid ILIKE ?", "%#{@query}%").page params[:page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
  end

  def show_uid
    render action: :show
  end

  def hide
    planning_application = PlanningApplication.find params[:id]
    hide_vote = planning_application.hide_votes.new.tap {|pl| pl.user = current_user}
    hide_vote.save

    @planning_application = PlanningApplicationDecorator.decorate planning_application.reload

    respond_to do |format|
      format.js {}
      format.html { render :show }
    end
  end

  def unhide
    planning_application = PlanningApplication.find params[:id]
    planning_application.hide_votes.find_by_user_id(current_user.id).destroy

    @planning_application = PlanningApplicationDecorator.decorate planning_application.reload

    respond_to do |format|
      format.js {}
      format.html { render :show }
    end
  end

  protected

  def set_planning_application
    planning_application = if params[:id]
                             PlanningApplication.find(params[:id])
                           else
                             PlanningApplication.for_local_authority(params[:authority_param]).find_by!(uid: params[:uid])
                           end
    @planning_application = PlanningApplicationDecorator.decorate planning_application
  end

  def planning_application_feature(planning_application)
    planning_application.loc_feature({ thumbnail: planning_application.medium_icon_path})
  end
end
