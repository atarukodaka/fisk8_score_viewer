class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.string :skater_name
      t.integer :rank
      t.integer :starting_number
      t.string :nation

      t.string :competition_name
      t.string :category
      t.string :segment
      t.datetime :starting_time
      t.string :result_pdf
      
      t.float :tss
      t.float :tes
      t.float :pcs
      t.float :deductions
      t.string :technicals_summary
      t.string :components_summary

      #t.timestamps
      t.belongs_to :competition
      t.references :skater
    end

    create_table :technicals do |t|
      t.integer :number
      t.string :element
      t.string :info
      t.float :base_value
      t.string :credit
      t.float :goe
      t.string :judges
      t.float :value

      t.belongs_to :score
    end

    create_table :components do |t|
      t.integer :number
      t.string :component
      t.float :factor
      t.string :judges
      t.float :value

      t.belongs_to :score
    end
  end
end
