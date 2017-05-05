class CreateCategoryResults < ActiveRecord::Migration
  def change
    create_table :category_results do |t|
      t.string :category

      t.integer :rank
      t.string :skater_name
      t.integer :isu_number
      t.string :nation
      t.float :points
      
      t.integer :short_ranking
      t.integer :free_ranking
      
      t.belongs_to :competition
      t.references :skater
    end
  end
end
