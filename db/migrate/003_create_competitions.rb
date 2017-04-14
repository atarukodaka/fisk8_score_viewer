class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.string :name
      t.string :city
      t.string :country
      t.date :start_date
      t.date :end_date
      t.string :isu_site
      
      t.timestamps
    end
  end
end
