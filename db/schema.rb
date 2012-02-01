# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120201123033) do

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "planners", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "parameters"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "planners", ["name", "version", "parameters"], :name => "index_planners_on_name_and_version_and_parameters", :unique => true

  create_table "problems", :force => true do |t|
    t.string   "name"
    t.integer  "subdomain_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "problems", ["subdomain_id"], :name => "index_problems_on_subdomain_id"

  create_table "solutions", :force => true do |t|
    t.integer  "planner_id"
    t.integer  "domain_id"
    t.integer  "subdomain_id"
    t.integer  "problem_id"
    t.integer  "plan_quality"
    t.integer  "second_plan_quality"
    t.integer  "steps"
    t.string   "notes"
    t.string   "full_solution"
    t.string   "full_raw_output"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "solutions", ["domain_id"], :name => "index_solutions_on_domain_id"
  add_index "solutions", ["planner_id"], :name => "index_solutions_on_planner_id"
  add_index "solutions", ["problem_id"], :name => "index_solutions_on_problem_id"
  add_index "solutions", ["subdomain_id"], :name => "index_solutions_on_subdomain_id"

  create_table "subdomains", :force => true do |t|
    t.string   "name"
    t.integer  "domain_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subdomains", ["domain_id"], :name => "index_subdomains_on_domain_id"

end
