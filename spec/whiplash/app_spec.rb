require 'spec_helper'

describe Whiplash::App do
  it 'has a version number' do
    expect(Whiplash::App::VERSION).not_to be nil
  end

end
