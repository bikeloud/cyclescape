require 'spec_helper'

describe Route::MessageApi do
  include Rack::Test::Methods

  describe 'GET /' do
    let(:response_keys) do
      [
        "id", "body", "censored_at", "created_at", "deleted_at",
        "in_reply_to_id", "status", "thread_id", "updated_at", "public_token"
      ]
    end
    let!(:resource) { create :message }

    before do
      get "/api/messages"
    end

    it "returns threads" do
      expect(json_response.size).to eq(1)
      expect(last_response.status).to eq(200)
      expect(json_response[0].keys).to match_array(response_keys)
    end
  end
end
