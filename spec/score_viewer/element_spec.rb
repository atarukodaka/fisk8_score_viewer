require 'spec_helper'

describe 'element' do
  before do
    skater = Skater.create(name: "AAA")
    score = Score.create
    score.skater = skater
    score.technicals.create(element: "4T", base_value: 15.0)
    score.technicals.create(element: "4T+3T", base_value: 10.0)
    score.save

  end

  after do
    Score.all.map(&:destroy)
  end

  describe 'element' do
    subject { get '/elements/list/element:4T' }
    its(:body) {
      should include("4T")
      should include("AAA")
      should include("15.0")
      should_not include("4T+3T")
      should_not include("10.0")
    }
  end

  describe 'element (partial_match)' do
    subject { get '/elements/list/element:4T/partial_match:1' }
    its(:body) {
      should include("4T")
      should include("AAA")
      should include("15.0")
      should include("4T+3T")
      should include("10.0")
    }
  end

end
