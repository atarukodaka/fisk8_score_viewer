# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 5) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "category_results", force: :cascade do |t|
    t.string  "category"
    t.integer "rank"
    t.string  "skater_name"
    t.integer "isu_number"
    t.string  "nation"
    t.float   "points"
    t.integer "short_ranking"
    t.integer "free_ranking"
    t.integer "competition_id"
    t.integer "skater_id"
    t.index ["competition_id"], name: "index_category_results_on_competition_id"
    t.index ["skater_id"], name: "index_category_results_on_skater_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "country"
    t.date   "start_date"
    t.date   "end_date"
    t.string "site_url"
    t.string "competition_type"
    t.string "season"
    t.string "short_name"
  end

  create_table "components", force: :cascade do |t|
    t.integer "number"
    t.string  "component"
    t.float   "factor"
    t.string  "judges"
    t.float   "value"
    t.integer "score_id"
    t.index ["score_id"], name: "index_components_on_score_id"
  end

  create_table "scores", force: :cascade do |t|
    t.string   "skater_name"
    t.integer  "rank"
    t.integer  "starting_number"
    t.string   "nation"
    t.string   "competition_name"
    t.string   "category"
    t.string   "segment"
    t.datetime "starting_time"
    t.string   "result_pdf"
    t.float    "tss"
    t.float    "tes"
    t.float    "pcs"
    t.float    "deductions"
    t.string   "technicals_summary"
    t.string   "components_summary"
    t.integer  "competition_id"
    t.integer  "skater_id"
    t.index ["competition_id"], name: "index_scores_on_competition_id"
    t.index ["skater_id"], name: "index_scores_on_skater_id"
  end

  create_table "skaters", force: :cascade do |t|
    t.string   "name"
    t.string   "nation"
    t.string   "category"
    t.integer  "isu_number"
    t.string   "isu_bio"
    t.date     "birthday"
    t.string   "coach"
    t.string   "choreographer"
    t.string   "hobbies"
    t.string   "height"
    t.string   "club"
    t.datetime "bio_updated_at"
  end

  create_table "technicals", force: :cascade do |t|
    t.integer "number"
    t.string  "element"
    t.string  "info"
    t.float   "base_value"
    t.string  "credit"
    t.float   "goe"
    t.string  "judges"
    t.float   "value"
    t.integer "score_id"
    t.index ["score_id"], name: "index_technicals_on_score_id"
  end

end
