# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "pages", :force => true do |t|
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "web_id",     :limit => 11, :default => 0, :null => false
    t.string   "locked_by",  :limit => 60
    t.string   "name",       :limit => 60
    t.datetime "locked_at"
  end

  create_table "revisions", :force => true do |t|
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.datetime "revised_at",                              :null => false
    t.integer  "page_id",    :limit => 11, :default => 0, :null => false
    t.text     "content"
    t.string   "author",     :limit => 60
    t.string   "ip",         :limit => 60
  end

  add_index "revisions", ["page_id"], :name => "index_revisions_on_page_id"
  add_index "revisions", ["created_at"], :name => "index_revisions_on_created_at"
  add_index "revisions", ["author"], :name => "index_revisions_on_author"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "system", :force => true do |t|
    t.string "password", :limit => 60
  end

  create_table "webs", :force => true do |t|
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "name",             :limit => 60, :default => "",        :null => false
    t.string   "address",          :limit => 60, :default => "",        :null => false
    t.string   "password",         :limit => 60
    t.string   "additional_style"
    t.integer  "allow_uploads",    :limit => 11, :default => 1
    t.integer  "published",        :limit => 11, :default => 0
    t.integer  "count_pages",      :limit => 11, :default => 0
    t.string   "markup",           :limit => 50, :default => "textile"
    t.string   "color",            :limit => 6,  :default => "008B26"
    t.integer  "max_upload_size",  :limit => 11, :default => 100
    t.integer  "safe_mode",        :limit => 11, :default => 0
    t.integer  "brackets_only",    :limit => 11, :default => 0
  end

  create_table "wiki_files", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "web_id",      :limit => 11, :null => false
    t.string   "file_name",                 :null => false
    t.string   "description",               :null => false
  end

  create_table "wiki_references", :force => true do |t|
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "page_id",         :limit => 11, :default => 0,  :null => false
    t.string   "referenced_name", :limit => 60, :default => "", :null => false
    t.string   "link_type",       :limit => 1,  :default => "", :null => false
  end

  add_index "wiki_references", ["page_id"], :name => "index_wiki_references_on_page_id"
  add_index "wiki_references", ["referenced_name"], :name => "index_wiki_references_on_referenced_name"

end
