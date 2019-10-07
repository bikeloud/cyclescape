# frozen_string_literal: true

class Message::PhotosController < Message::BaseController
  def show
    @photo = resource_class.find params[:id]
  end

  protected

  def resource_class
    PhotoMessage
  end

  def permit_params
    
  end
end
