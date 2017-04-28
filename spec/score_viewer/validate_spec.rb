require 'spec_helper'

describe 'validate' do
  before {
    logger = Logger.new(STDOUT)
    logger.extend(Padrino::Logger::Extensions)
    Padrino.logger = logger
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:production])
  }
  after {
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Padrino.env])
  }
  it {
    Skater.order(:name).each do |skater|
      logger.debug(" #{skater.name}")
      expect(skater.name).not_to eq('')
      expect(skater.nation).to match /^[A-Z][A-Z][A-Z]$/
      expect(skater.category).to match /^[\w\s]+$/
#      expect(skater.scores.count).not_to eq(0)
    end
  }
  it {
    Competition.order("start_date DESC").each do |competition|
      logger.debug(" #{competition.name}")

      expect(competition.name).not_to eq('')
      expect(competition.city).not_to eq('')
      expect(competition.country).to match /^[A-Z][A-Z][A-Z]$/
      competition.scores.each do |score|
        logger.debug("  [#{score.category}/#{score.segment}]#{score.rank}:#{score.skater_name}")
        [:skater_name, :competition_name, :competition_id, :category, :segment,
         :starting_time, :tss, :tes, :pcs, :deductions, :result_pdf,].each do |key|
          expect(score[key]).not_to eq('')
        end

        ## technicals
        if ENV["validate_technicals"]   # taks a time...
          score.technicals.each do |element|
            expect(element.element).not_to eq('')
            expect(element.number).not_to be_nil
            expect(element.value).not_to be_nil
          end
        end
        ## components
        if ENV['validate_components']
          score.components.each do |component|
            expect(component.component).not_to eq('')
            expect(component.value).not_to be_nil          
          end
        end
      end
    end
  }
end
