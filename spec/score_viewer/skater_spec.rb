require 'spec_helper'

describe 'skater' do
  before do
    Skater.create(name: "Skater NAME", nation: "JPN")
  end
  after do
    Skater.all.map(&:destroy)
  end

  describe 'skaters/id' do
    subject { id = Skater.first.id; get "/skaters/id/#{id}" }
    its(:body) { should include('Skater NAME') }
  end

  describe 'skaters/name' do
    subject { get '/skaters/name/Skater%20NAME' }
    its(:body) { should include('Skater NAME') }
  end
end ## describe

