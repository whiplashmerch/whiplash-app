require 'spec_helper'

describe Whiplash::App do
  it 'has a version number' do
    expect(Whiplash::App::VERSION).not_to be nil
  end

  describe '#client' do
    it 'has an oauth client' do
      expect(Whiplash::App.client).to be_a OAuth2::Client
    end
  end

  describe '#connection' do
    it 'has a faraday connection' do
      Whiplash::App.stub(:token).and_return("bacon")
      expect(Whiplash::App.connection).to be_a Faraday::Connection
    end
  end

end
