# frozen_string_literal: true

class PlanningApplicationDecorator < ApplicationDecorator
  alias planning_application object

  def issue_link
    h.link_to issue.title, planning_application.issue
  end

  def map
    h.render partial: "planning_applications/map", locals: { planning_application: self }
  end

  def tinymap
    h.render partial: "planning_applications/tinymap", locals: { planning_application: self }
  end

  def medium_icon_path(default = true)
    icon_path("m", default)
  end

  def icon_path(size, default = true)
    icon = nil
    icon ||= "planning" if default
    return "" if icon.nil?

    h.image_path "map-icons/#{size}-#{icon}.png"
  end
end
