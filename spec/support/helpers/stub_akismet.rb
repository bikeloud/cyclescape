# frozen_string_literal: true

module RSpec
  module Helpers
    module StubAkismet
      extend ActiveSupport::Concern

      included do
        before do
          stub_request(:post, %r{rest\.akismet\.com/1\.1/comment-check}).to_return(status: 200, body: "false")
        end
      end
    end
  end
end
