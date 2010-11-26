require File.expand_path(File.dirname(__FILE__) + "/../lib/active_conductor")
require "active_record"

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'

ActiveRecord::Schema.define do
  create_table :people do |t|
    t.string :name
    t.timestamps
  end

  create_table :records do |t|
    t.integer :an_int
    t.timestamps
  end
end

class Record < ActiveRecord::Base
end

class Person < ActiveRecord::Base
  validates_presence_of :name
end