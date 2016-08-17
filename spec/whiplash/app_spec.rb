require "spec_helper"

describe Whiplash::App do
  it "has a version number" do
    expect(Whiplash::App::VERSION).not_to be nil
  end

  describe "#client" do
    it "has an oauth client" do
      expect(Whiplash::App.client).to be_a OAuth2::Client
    end
  end

  describe "#connection" do
    it "has a faraday connection" do
      allow(Whiplash::App).to receive(:token).and_return("bacon")
      expect(Whiplash::App.connection).to be_a Faraday::Connection
    end
  end

  context "GET calls" do
    describe "#find_all" do
      subject(:response) { Whiplash::App.find_all('customers') }

      it "should return a 200 status" do
        expect(response.status).to eq 200
      end

      it "returns all of a specified resource" do
        @customers = response.body
        expect(@customers).to be_a Array
      end
    end

    describe "#find" do
      before do
        response = Whiplash::App.find_all('customers')
        @customer_id = response.body.first["id"]
      end

      subject(:response) { Whiplash::App.find('customers', @customer_id) }

      it "should return a 200 status" do
        expect(response.status).to eq 200
      end

      it "returns a singular resource" do
        customer = response.body
        expect(customer).to be_a Hash
      end
    end

    describe "#count" do

      let(:customers) { Whiplash::App.find_all('customers').body }

      subject(:response) { Whiplash::App.count('customers') }

      it "returns an integer" do
        expect(response).to be_an Integer
      end

      it "returns the count of the given resource" do
        expect(response).to eq customers.count
      end
    end
  end

  describe "POST/PUT/DELETE requests" do
    let(:customer_id) { Whiplash::App.find_all('customers').body.first["id"] }
    let(:response) do
      Whiplash::App.create('items', { sku: "TEST123",title: "Test Item"},
      { customer_id: customer_id })
    end
    let(:item_id) { response.body["id"] }


    describe "#create" do

      it "should return a 201 status" do
        expect(response.status).to eq 201
      end

      it "finds the newly created item" do
        new_item = Whiplash::App.find('items', item_id).body
        expect(new_item["sku"]).to eq "TEST123"
      end
    end

    describe "#update" do
      it "has an updated sku value" do
        Whiplash::App.update('items', item_id, { sku: "TEST1234" })
        item = Whiplash::App.find('items', item_id).body
        expect(item["sku"]).to eq "TEST1234"
      end
    end

  end

end
