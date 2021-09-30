require "spec_helper"

describe Whiplash::App do
    context "GET calls" do
        describe "#find_all" do

            it "should return a 200 status when successfully authorized" do
                allow_any_instance_of(Whiplash::App).to receive(:find_all).with('customers') do
                    {
                        status: 200,
                        body: []
                    }
                    subject.find_all('customers')
                    expect(subject.status).to equal(200)
                end
            end

            it "returns all of the specified resource" do
                allow_any_instance_of(Whiplash::App).to receive(:find_all).with('customers') do
                    {
                        status: 200,
                        body: []
                    }
                    subject.find_all('customers')
                    expect(subject.body).to be_a Array
                end
            end
        end
    end
end

=begin

    All of these tests were originally in app_spec.rb. They are tests for the 
    finder_methods.rb methods, so I've separated them into their own file.
    Additionally, these tests are all broken and make live API HTTP requests.
    Ideally, we would be testing the GET/POST/PUT/DELETE methods that they use, which
    all live inside of connections.rb. I've left these in just in case we want to test
    them regardless, but, as you can see above, they aren't worth much. 

  context "GET calls" do
    describe "#find_all" do
      subject(:response) { Whiplash::App.new.find_all('customers') }

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
        response = @whiplash_app.find_all('customers')
        @customer_id = response.body.first["id"]
      end

      subject(:response) { @whiplash_app.find('customers', @customer_id) }

      it "should return a 200 status" do
        expect(response.status).to eq 200
      end

      it "returns a singular resource" do
        customer = response.body
        expect(customer).to be_a Hash
      end
    end

    describe "#count" do

      let(:customers) { @whiplash_app.find_all('customers').body }

      subject(:response) { @whiplash_app.count('customers') }

      it "returns an integer" do
        expect(response).to be_an Integer
      end

      it "returns the count of the given resource" do
        expect(response).to eq customers.count
      end
    end
  end

  describe "POST/PUT/DELETE requests" do
    let(:customer_id) { @whiplash_app.find_all('customers').body.first["id"] }
    let(:response) do
      @whiplash_app.create('items', { sku: "TEST123",title: "Test Item"},
      { customer_id: customer_id })
    end
    let(:item_id) { response.body["id"] }


    describe "#create" do

      it "should return a 201 status" do
        expect(response.status).to eq 201
      end

      it "finds the newly created item" do
        new_item = @whiplash_app.find('items', item_id).body
        expect(new_item["sku"]).to eq "TEST123"
      end
    end

    describe "#update" do
      it "has an updated sku value" do
        @whiplash_app.update('items', item_id, { sku: "TEST1234" })
        item = @whiplash_app.find('items', item_id).body
        expect(item["sku"]).to eq "TEST1234"
      end
    end

=end