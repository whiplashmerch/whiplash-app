require "spec_helper"

describe Whiplash::App do
  before do
    allow_any_instance_of(Whiplash::App).to receive(:token).and_return(double(token: 'access token'))
    @whiplash_app = Whiplash::App.new
  end

  it "has a version number" do
    expect(Whiplash::App::VERSION).not_to be nil
  end

  describe "#client" do
    it "has an oauth client" do
      expect(@whiplash_app.client).to be_a OAuth2::Client
    end
  end

  describe "#connection" do
    it "has a faraday connection" do
      expect(@whiplash_app.connection).to be_a Faraday::Connection
    end
  end
end

