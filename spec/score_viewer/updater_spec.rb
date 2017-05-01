require 'spec_helper'

describe 'update_competition' do
  let (:site_url) { 'http://www.isuresults.com/results/season1617/gpjpn2016/' }
  before {
    if t = Competition.find_by(site_url: site_url)
      t.destroy
    end
  }
  after {
    Competition.all.map(&:destroy)
  }
  
  subject(:competition) {
    updater = Fisk8Viewer::Updater.new
    updater.update_competition(site_url)

    Competition.find_by(site_url: site_url)
  }
  it { expect(competition.name).to eq('ISU GP NHK Trophy 2016') }
  it { expect(competition.city).to eq('Sapporo') }
  it { expect(competition.country).to eq('JPN') }
  it { expect(competition.category_results.where(category: "MEN", rank: 1).first.skater_name).to eq('Yuzuru HANYU') }
end

describe 'skater', type: :skater do
  before {
    Skater.all.map(&:destroy)
    Skater.create(name: 'Yuzuru HANYU', category: 'MEN', nation: 'JPN')
    updater = Fisk8Viewer::Updater.new
    updater.update_skater_bio
  }
  after {
    Skater.all.map(&:destroy)
  }
  subject(:skater) {
    skater = Skater.find_by(name: 'Yuzuru HANYU')
  }
  its(:category) { should eq('MEN') }
  its(:nation) { should eq('JPN') }  
  its(:isu_number) { should eq(10967) }  
  its(:height) { should eq('171') }
end
