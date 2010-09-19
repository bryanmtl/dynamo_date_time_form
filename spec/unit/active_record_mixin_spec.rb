require File.join(File.dirname(__FILE__), '../spec_helper')

describe SemanticGap::DateTimeForm::ActiveRecordMixin::ClassMethods do
  describe '#datetime_fields_for' do
    before(:each) do
      @klass = Class.new do
        def self.validate(meth); end
        def self.before_save(meth); end

        include SemanticGap::DateTimeForm::ActiveRecordMixin
        datetime_fields_for :published_at
      end
    end

    subject { @klass.new }

    context 'for a field named "published_at"' do
      it "defines 'published_at_fields'" do
        subject.should respond_to(:published_at_fields)
      end

      it "defines 'publihsed_at_fields='" do
        subject.should respond_to(:published_at_fields=)
      end
    end
  end
end

describe SemanticGap::DateTimeForm::ActiveRecordMixin do
  it "is included into ActiveRecord::Base" do
    ActiveRecord::Base.should include(SemanticGap::DateTimeForm::ActiveRecordMixin)
  end

  describe '.included' do
    it "adds #datetime_fields_for to the class" do
      klass = Class.new
      klass.send(:include, SemanticGap::DateTimeForm::ActiveRecordMixin)
      klass.should respond_to(:datetime_fields_for)
    end
  end
end
