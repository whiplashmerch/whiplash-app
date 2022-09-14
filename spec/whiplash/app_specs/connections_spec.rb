require "spec_helper"

describe Whiplash::App::Connections do
  let(:first_request) { OpenStruct.new(success?: true, body: (1..50).to_a) }
  let(:second_request) { OpenStruct.new(success?: true, body: (1..10).to_a) }
  let(:whiplash_app) { Whiplash::App.new }

  before do
    allow_any_instance_of(Whiplash::App).to receive(:token).and_return(double(token: 'access token'))
    allow_any_instance_of(Faraday::Connection).to receive(:send).with(:get, "core_url", {:per_page=>50}, {"Accept-Version"=>"v2"}).and_return(first_request)
    allow_any_instance_of(Faraday::Connection).to receive(:send).with(:get, "core_url", {:page => 2, :per_page=>50}, {"Accept-Version" => "v2"}).and_return(second_request)
  end

  context 'GET calls' do
    describe '#multi_page_get!' do
      it 'returns a Faraday response' do
          expect(whiplash_app.multi_page_get!('core_url', {}, nil).class).to equal Faraday::Response
      end

      it 'returns a successful response' do
        res = whiplash_app.multi_page_get!('core_url', {}, nil) 
        expect(res.status).to eq(200)
      end

      it 'returns an array in the body' do
        res = whiplash_app.multi_page_get!('core_url', {}, nil)
        puts "HERE"
        puts res
        puts res.body
        puts res.status
        expect(res.body.class).to eq(Array)
      end

      it 'returns the correct numbers of results' do
          expect(whiplash_app.multi_page_get!('core_url', {}, nil).body.size).to eq(60)
      end
    end
  end
end
