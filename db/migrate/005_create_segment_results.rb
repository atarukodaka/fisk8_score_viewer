class CreateSegmentResults < ActiveRecord::Migration
  def change
    create_table :segment_results do |t|
      t.string :category
      t.string :segment      

      t.integer :rank
      t.string :skater_name
      t.integer :isu_number
      t.integer :starting_number
      
      t.float :tss
      t.float :tes
      t.float :pcs
      t.float :deductions
      
      t.belongs_to :competition
      t.references :skater
    end
  end
end
