require 'spec_helper'

describe 'score' do
  before do
    competition = Competition.create(name: "ISU World Figure", competition_type: "world", season: "2016-17")
    competition.scores.create(skater_name: "Skater NAME", category: "MEN", segment: "SHORT PROGRAM", nation: "JPN", rank: 1)
  end
  after do
    Competition.all.map(&:destroy)
  end

  let (:id) { Score.first.id }
  
  describe 'id' do
    subject { get "/scores/id/#{id}" }
    its(:body) { should include('Skater NAME')}
  end

  ## list
  describe 'list' do
    subject { get '/scores/list/' }
    its(:body) { should include('Skater NAME') }
  end

  describe 'list/category' do
    subject { get '/scores/list/category:MEN' }
    its(:body) {
      should include('Skater NAME')
      should include('MEN')
    }
  end
end

