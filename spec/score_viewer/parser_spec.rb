require 'spec_helper'

describe 'score' do
  subject (:score){
    filename = "pdf/wtt2013_Pairs_SP_P_Scores.pdf"
    parser = Fisk8Viewer::ScoreParser.new
    url = "http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf"
    hash = parser.parse(url)
    score = hash.select {|elem| elem[:rank] == 1}.first
    Hashie::Mash.new(score)
  }
  its(:skater_name) { should eq('Yuzuru HANYU') }
  its(:nation) { should eq('JPN') }
  it { expect(score[:technicals][0].element).to eq('4Lo') }
  it { expect(score[:technicals][0].base_value).to eq(12.0) }
  it { expect(score[:technicals][0].value).to eq(9.37) }
  it { expect(score[:components][0].component).to eq('Skating Skills') }
  it { expect(score[:components][0].value).to eq(9.39) }
  
end

describe 'competition summary' do
  subject (:parsed){
    url = 'http://www.isuresults.com/results/season1617/gpjpn2016/'
    parser = Fisk8Viewer::CompetitionParser::ISU_Generic.new
    Fisk8Viewer::CompetitionSummaryAdaptor.new(parser.parse_summary(url))
  }
  its(:categories) { should eq(["ICE DANCE", "LADIES", "MEN", "PAIRS"]) }
  it { expect(parsed.segments('MEN')).to eq(['SHORT PROGRAM', 'FREE SKATING']) }
  it { expect(parsed.result_url('MEN')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM') }
  it { expect(parsed.score_url('MEN', 'SHORT PROGRAM')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf') }
  it { expect(parsed.starting_time('MEN', 'SHORT PROGRAM')).to eq(Time.zone.parse('2016/11/25 19:11:30')) }
end

describe 'competition category result' do
  subject (:result) {
    url = 'http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM'
    parser = Fisk8Viewer::CompetitionParser::ISU_Generic.new
    Hashie::Mash.new(parser.parse_category_result(url).select {|e| e[:rank] == 1 }.first)
  }
  its(:skater_name) { should eq('Yuzuru HANYU') }
  its(:nation) { should eq('JPN') }
  its(:points) { should eq(301.47) }
  
end

