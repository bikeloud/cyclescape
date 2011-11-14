class LibrariesController < ApplicationController
  def show
    @recent_documents = Library::Document.recent(5)
    @recent_notes = Library::Note.recent(5)
  end
end