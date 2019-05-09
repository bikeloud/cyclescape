# frozen_string_literal: true

akismet_file = Rails.root.join("config", "akismet")
if akismet_file.exist?
  Cyclescape::Application.config.rakismet.key = akismet_file.read.strip
  Cyclescape::Application.config.rakismet.url = "http://www.cyclescape.org/"
elsif %w[development test].include? Rails.env
  Cyclescape::Application.config.rakismet.key = "development"
  Cyclescape::Application.config.rakismet.url = "http://www.cyclescape.org/"
end
