require File.join(File.dirname(__FILE__), '../spec_helper')

describe SemanticGap::DateTimeForm::FormBuilderMixin do
  include ActionController::Assertions::SelectorAssertions

  def build_view
    v = ActionView::Base.new
    v.send(:extend, ActionView::Helpers::FormHelper)
    v.send(:extend, ActionView::Helpers::DateHelper)
    v.send(:extend, ActionView::Helpers::FormOptionsHelper)
    v.send(:extend, ActionView::Helpers::TagHelper)
    v
  end

  before(:each) do
    @fields = SemanticGap::DateTimeForm::Form.new(:time_zone => ActiveSupport::TimeZone.new('Eastern Time (US & Canada)'))
    @object = mock('object', :published_at_fields => @fields)
    @template = build_view
    @options = { }
  end

  subject { ActionView::Helpers::FormBuilder.new('object', @object, @template, @options, nil) }

  it "is included into ActionView::Helpers::FormBuilder" do
    ActionView::Helpers::FormBuilder.should include(SemanticGap::DateTimeForm::FormBuilderMixin)
  end

  describe '#datetime_form' do
    TagArgs = {
      :year => [ 'input[type=?][size=?][name=?]', 'text', '4', 'object[published_at_fields][year]' ],
      :month => [ 'select[name=?]', 'object[published_at_fields][month]' ],
      :day => [ 'input[type=?][size=?][name=?]', 'text', '2', 'object[published_at_fields][day]' ],
      :hour => [ 'input[type=?][size=?][name=?]', 'text', '2', 'object[published_at_fields][hour]' ],
      :minute => [ 'input[type=?][size=?][name=?]', 'text', '2', 'object[published_at_fields][minute]' ],
      :ampm => [ 'select[name=?]', 'object[published_at_fields][ampm]' ],
      :time_zone => [ 'span[class=?]', 'timezone', 'Eastern Time (US & Canada)' ]
    }

    context 'basic datetime form' do
      before(:each) do
        @result = subject.datetime_form(:published_at)
      end

      it "returns a div with class 'sg-datetime-form'" do
        @result.should have_tag('div', :class => 'sg-datetime-form') do
          with_tag(*TagArgs[:year])
          with_tag(*TagArgs[:month])
          with_tag(*TagArgs[:day])
          with_tag(*TagArgs[:hour])
          with_tag(*TagArgs[:minute])
          with_tag(*TagArgs[:ampm])
          with_tag(*TagArgs[:time_zone])
        end
      end

      it "has a text field for the year" do
        @result.should have_tag(*TagArgs[:year])
      end

      it "has a select field for the month" do
        @result.should have_tag(*TagArgs[:month])
      end

      it "has a text field for the day" do
        @result.should have_tag(*TagArgs[:day])
      end

      it "has a text field for the hour" do
        @result.should have_tag(*TagArgs[:hour])
      end

      it "has a text field for the minute" do
        @result.should have_tag(*TagArgs[:minute])
      end

      it "has a select field for ampm" do
        @result.should have_tag(*TagArgs[:ampm])
      end

      it "has shows the time zone" do
        @result.should have_tag(*TagArgs[:time_zone])
      end
    end

    context 'when the fields allow blank' do
      before(:each) do
        @fields.stub!(:allow_blank?).and_return(true)
        @result = subject.datetime_form(:published_at)
      end

      it "includes a blank option in the month select field" do
        @result.should have_tag(*TagArgs[:month]) do
          with_tag('option[value=?]', '')
        end
      end
    end

    [ 2, '2' ].each do |month|
      context "when month is #{month.inspect}" do
        before(:each) do
          @fields.month = month
          @result = subject.datetime_form(:published_at)
        end

        it "has an option for the selected month" do
          @result.should have_tag('option[value=?][selected=selected]', month)
        end
      end
    end
  end
end
