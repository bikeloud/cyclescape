# frozen_string_literal: true

class Library::ItemDecorator < ApplicationDecorator
  alias item object

  def link
    h.link_to item.title, h.url_for(item.component)
  end

  def icon
    h.content_tag(:span, nil, class: "icon #{h.dom_class(item.component)}")
  end

  def description
    if item.component.respond_to?(:body)
      h.truncate item.component.body
    else
      ""
    end
  end

  def as_json(_options = nil)
    {
      id: item.id,
      title: item.title,
      link: link,
      icon: icon,
      description: description,
      item_type: h.dom_class(item.component)
    }
  end
end
