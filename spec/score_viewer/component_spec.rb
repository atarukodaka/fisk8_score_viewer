require 'spec_helper'

describe 'component' do
  before do
    skater = Skater.create(name: "AAA")
    score = Score.create(skater_id: skater.id, skater_name: "AAA")
    score.components.create(component: "Skating Skill", number: 1, value: 10.0)
    score.components.create(component: "Transition", number: 2, value: 9.0)
  end

  after do
    Score.all.map(&:destroy)
  end

  describe 'component/number' do
    subject { get '/components/list/component_number:1' }
    its(:body) {
      should include("10.0")
      should_not include("9.0")
    }
  end

  describe 'component/skater_name/number' do
    subject { get '/components/list/skater_name:AAA' }
    its(:body) {
      should include("AAA")
      should include("10.0")
      should include("9.0")
    }
  end

end
