require File.join(File.dirname(__FILE__), '../spec_helper')
require 'semanticgap_date_time_form/spec'

class Post < ActiveRecord::Base
  class Migration < ActiveRecord::Migration
    def self.up
      create_table :posts do |t|
        t.datetime :published_at
        t.datetime :created_at
      end
    end
  end

  datetime_fields_for :created_at
  datetime_fields_for :published_at, :allow_blank => true
end

describe Post do
  include SemanticGap::DateTimeForm::Spec

  before(:all) do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'test.sqlite3')
    Post::Migration.up
  end

  after(:all) do
    FileUtils.rm('test.sqlite3')
  end

  before(:each) do
    subject.created_at = DateTime.now
  end

  it_has_datetime_fields_for :published_at, :allow_blank => true
  it_has_datetime_fields_for :created_at
end
