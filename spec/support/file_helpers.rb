# frozen_string_literal: true

def lorem_ipsum_path
  File.join(%w[spec support text lorem.txt])
end

def abstract_image_path
  File.join(%w[spec support images abstract-100-100.jpg])
end

def test_photo_path
  File.join(%w[spec support images cycle-photo-1.jpg])
end

def profile_photo_path
  File.join(%w[spec support images profile-image.jpg])
end

def pdf_document_path
  File.join(%w[spec support documents use_cases.pdf])
end

def word_document_path
  File.join(%w[spec support documents use_cases.doc])
end

def raw_email_path(type = "basic")
  File.join(%W[spec support text #{type}_email.txt])
end

def planning_applications_path
  File.join(%w[spec support text planning_applications.csv])
end
