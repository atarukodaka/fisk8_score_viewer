require 'spec_helper'


describe 'competition' do
  before do
    cmp = Competition.create(name: "ISU World Figure", competition_type: "world", season: "2016-17")
    cmp.category_results.create(category: "MEN")
    score = cmp.scores.create(skater_name: "Foo BAR", category: "MEN", segment: "SHORT PROGRAM")
    score.skater = Skater.create(name: score.skater_name)
    score.save
  end
  
  after do
    Competition.all.map(&:destroy)
  end
  
  let (:id) { Competition.last.id }
  
  describe 'id' do
    subject { get "/competitions/id/#{id}" }
    its(:body) { should include('ISU World') }
  end

  describe 'id/MEN' do
    subject { get "/competitions/id/#{id}/MEN" }
    its(:body) {
      should include('ISU World');
      should include('MEN')
    }
  end

  describe 'id/MEN/SHORT PROGRAM' do
    subject { get "/competitions/id/#{id}/MEN/SHORT%20PROGRAM" }
    its(:body) {
      should include('ISU World');
      should include('MEN');
      should include('SHORT PROGRAM')
    }
  end

  describe 'name/xxx' do
    subject { get '/competitions/name/ISU%20World%20Figure' }
    its(:body) { should include('ISU World') }
  end

  ## list
  describe 'redirect' do
    subject(:response) { get '/competitions'}
    its(:status) { should eq 302 }
    it { expect(response.header["Location"]).to include("/competitions/list/") }
  end

  describe 'list/' do 
    subject { get "/competitions/list/" }
    its(:body) { should include('ISU World') }
  end
  
  describe 'list/competition_type' do
    subject { get "/competitions/list/competition_type:world" }
    its(:body) {
      should include('ISU World')
      should include('world')
    }
  end
  
  describe 'list/season' do
    subject { get "/competitions/list/season:2016-17" }
    its(:body){
      should include('ISU World')
      should include('2016-17')
    }
  end
end
