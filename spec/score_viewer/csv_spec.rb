require 'spec_helper'

describe 'csv' do
  describe 'score' do
    before {
      Score.create(skater_name: "foo")
    }
    after {
      Score.all.map(&:destroy)
    }
    subject (:response) {
      get '/scores/list/skater_name:foo.csv'
    }
    its(:body) { should include("foo") }
  end

  describe 'skater' do
    before {
      Skater.create(name: "foo")
    }
    after {
      Skater.all.map(&:destroy)
    }
    subject (:response) {
      get '/skaters/list/name:foo.csv'
    }
    its(:body) { should include("foo") }
  end

  describe 'element' do
    before {
      score = Score.create
      score.technicals.create(element: "4T")
    }
    after {
      Score.all.map(&:destroy)
    }
    subject (:response) {
      get '/elements/list/element:4T.csv'
    }
    its(:body) { should include("4T") }
  end

  describe 'component' do
    before {
      score = Score.create
      score.components.create(number: 1, value: 9.3)
    }
    after {
      Score.all.map(&:destroy)
    }
    subject (:response) {
      get '/components/list/.csv'
    }
    its(:body) { should include("9.3") }
  end

end
