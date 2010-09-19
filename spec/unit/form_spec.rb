require File.join(File.dirname(__FILE__), '../spec_helper')

describe SemanticGap::DateTimeForm::Form do
  def self.it_has_the_attributes(*attrs)
    attrs.each do |attr|
      describe "\##{attr}" do
        it "is an accessor for @#{attr}" do
          subject.send(:instance_variable_set, "@#{attr}", :hello)
          subject.send(attr).should == :hello
        end
      end

      describe "\##{attr}=" do
        it "changes @#{attr}" do
          lambda { subject.send("#{attr}=", :hello) }.
            should change { subject.send(:instance_variable_get, "@#{attr}") }.
            to(:hello)
        end
      end
    end
  end

  Attributes = [ :year, :month, :day, :hour, :minute, :ampm ]

  it "is an active form" do
    subject.should be_kind_of(ActiveForm)
  end

  it_has_the_attributes :year, :month, :day
  it_has_the_attributes :hour, :minute, :ampm
  it_has_the_attributes :time_zone

  describe '#initialize' do
    context 'no arguments' do
      subject { described_class.new }

      context 'when Time.zone is set' do
        before(:each) do
          @old_zone = Time.zone
          Time.zone = ActiveSupport::TimeZone.new('Eastern Time (US & Canada)')
          Time.zone.should_not be_nil
        end

        after(:each) do
          Time.zone = @old_zone
        end

        it "sets the time zone to Time.zone" do
          subject.time_zone.should == Time.zone
        end
      end

      context 'when Time.zone is unset' do
        before(:each) do
          @old_zone = Time.zone
          Time.zone = nil
        end

        after(:each) do
          Time.zone = @old_zone
        end

        it "sets the time zone to UTC" do
          subject.time_zone.should == ActiveSupport::TimeZone.new('UTC')
        end
      end

      it "does NOT allow blanks" do
        subject.should_not be_allow_blank
      end

      it "is not valid" do
        subject.should_not be_valid
      end

      it "leaves the attributes blank" do
        Attributes.each do |attr|
          subject.send(attr).should be_nil
        end
      end
    end

    context 'options hash' do
      context 'with :allow_blank' do
        subject { described_class.new(:allow_blank => true) }

        it "allows blanks" do
          subject.should be_allow_blank
        end

        it "is valid" do
          subject.should be_valid
        end
      end

      context 'with :time_zone' do
        before(:each) do
          @zone = ActiveSupport::TimeZone.new('Eastern (US & Canada)')
        end

        subject do
          described_class.new(:time_zone => @zone)
        end

        it "sets the time zone to the supplied value" do
          subject.time_zone.should == @zone
        end
      end
    end

    context 'with a DateTime' do
      { DateTime.new(2010, 5, 6, 20, 1) => %W(2010 5 6 08 01 PM),
        DateTime.new(2010, 5, 6, 8, 59) => %W(2010 5 6 08 59 AM),
      }.each do |date, (year, month, day, hour, minute, ampm)|
        context "with #{date}" do
          subject { described_class.new(date) }

          it "sets the attributes to the DateTime's components" do
            subject.year.should == year.to_i
            subject.month.should == month.to_i
            subject.day.should == day.to_i
            subject.hour.should == hour
            subject.minute.should == minute
            subject.ampm.should == ampm
          end
        end
      end
    end

    context 'with a DateTime and options Hash' do
      before(:each) do
        @date = DateTime.new(2010, 5, 6, 20, 1)
        @zone = ActiveSupport::TimeZone.new('Eastern Time (US & Canada)')
      end

      subject { described_class.new(@date, :allow_blank => true, :time_zone => @zone) }

      it "sets the date to the DateTime" do
        subject.to_datetime.should == @date
      end

      it "sets the options" do
        subject.should be_allow_blank
        subject.time_zone.should == @zone
      end
    end
  end

  describe 'validations' do
    describe 'when blanks are allowed' do
      subject { described_class.new(:allow_blank => true) }

      it "is valid when all attributes are blank" do
        subject.should be_valid
      end

      it "is valid when all attributes are blank except ampm" do
        subject.ampm = 'AM'
        subject.should be_valid
      end

      [ :year, :month, :day, :hour, :minute ].each do |attr|
        it "is invalid if #{attr} has a value" do
          subject.send("#{attr}=", 1)
          subject.should_not be_valid
        end
      end
    end

    describe 'on year' do
      { 1 => true,
        2010 => true,
        0 => true,
        14 => true,
        -1 => true,
        '-10' => true,
        '-1' => true,
        'A' => false,
        'abcd' => false,
        '' => false,
        ' ' => false
      }.each do |value, valid|
        it "is #{valid ? 'valid' : 'invalid'} for #{value}" do
          subject.year = value

          if valid
            subject.should_not have(:any).errors_on(:year)
          else
            subject.should have_at_least(1).error_on(:year)
          end
        end
      end
    end

    describe 'on month' do
      it "must be between 1 and 12" do
        (1..12).each do |i|
          subject.month = i
          subject.should_not have(:any).errors_on(:month)
        end
      end

      { 1 => true,
        12 => true,
        '10' => true,
        0 => false,
        14 => false,
        -1 => false,
        '-10' => false,
        '-1' => false,
        'A' => false,
        '' => false,
        ' ' => false
      }.each do |value, valid|
        it "is #{valid ? 'valid' : 'invalid'} for #{value}" do
          subject.month = value

          if valid
            subject.should_not have(:any).errors_on(:month)
          else
            subject.should have_at_least(1).error_on(:month)
          end
        end
      end
    end

    describe 'on day' do
      context 'with a blank month' do
        before(:each) do
          subject.month = nil
        end

        it "must be between 1 and 31" do
          (1..31).each do |i|
            subject.day = i
            subject.should_not have(:any).errors_on(:day)
          end
        end

        { '1' => true,
          '31' => true,
          '10' => true,
          0 => false,
          32 => false,
          -1 => false,
          '-10' => false,
          '-1' => false,
          'A' => false,
          '' => false,
          ' ' => false
        }.each do |value, valid|
          it "is #{valid ? 'valid' : 'invalid'} for #{value}" do
            subject.day = value

            if valid
              subject.should_not have(:any).errors_on(:day)
            else
              subject.should have_at_least(1).error_on(:day)
            end
          end
        end
      end

      { 2010 => {
          1 => 31,
          2 => 28,
          3 => 31,
          4 => 30,
          5 => 31,
          6 => 30,
          7 => 31,
          8 => 31,
          9 => 30,
          10 => 31,
          11 => 30,
          12 => 31
        },
        2008 => {
          1 => 31,
          2 => 29,
          3 => 31,
          4 => 30,
          5 => 31,
          6 => 30,
          7 => 31,
          8 => 31,
          9 => 30,
          10 => 31,
          11 => 30,
          12 => 31
        }
      }.each do |year, months|
        context "in the year #{year}" do
          subject { described_class.new(:allow_blank => true) }

          before(:each) do
            subject.year = year
          end

          months.each do |month, num_days|
            context "with month set to #{month}" do
              before(:each) do
                subject.month = month
              end

              it "is valid when day is set to #{num_days - 1}" do
                subject.day = num_days - 1
                subject.should be_valid
              end

              it "is valid when day is set to #{num_days}" do
                subject.day = num_days
                subject.should be_valid
              end

              it "is invalid when day is set to #{num_days + 1}" do
                subject.day = num_days + 1
                subject.should_not be_valid
                subject.should have_at_least(1).error_on(:day)
              end
            end
          end
        end
      end
    end

    describe 'hour' do
      it "must be between 0 and 23" do
        (0..23).each do |i|
          subject.hour = i
          subject.should_not have(:any).errors_on(:hour)
        end
      end

      { '0' => true,
        '12' => true,
        23 => true,
        '10' => true,
        24 => false,
        25 => false,
        -1 => false,
        '-10' => false,
        '-1' => false,
        'A' => false,
        '' => false,
        ' ' => false
      }.each do |value, valid|
        it "is #{valid ? 'valid' : 'invalid'} for #{value.inspect}" do
          subject.hour = value

          if valid
            subject.should_not have(:any).errors_on(:hour)
          else
            subject.should have_at_least(1).error_on(:hour)
          end
        end
      end
    end

    describe 'minute' do
      it "must be between 0 and 59" do
        (0..59).each do |i|
          subject.minute = i
          subject.should_not have(:any).errors_on(:minute)
        end
      end

      { '0' => true,
        '59' => true,
        59 => true,
        '10' => true,
        60 => false,
        61 => false,
        -1 => false,
        '-10' => false,
        '-1' => false,
        'A' => false,
        '' => false,
        ' ' => false
      }.each do |value, valid|
        it "is #{valid ? 'valid' : 'invalid'} for #{value.inspect}" do
          subject.minute = value

          if valid
            subject.should_not have(:any).errors_on(:minute)
          else
            subject.should have_at_least(1).error_on(:minute)
          end
        end
      end
    end

    describe 'ampm' do
      %W(am AM aM Am pm PM pM Pm).each do |value|
        it "is valid with #{value.inspect}" do
          subject.ampm = value
          subject.should_not have(:any).errors_on(:ampm)
        end
      end

      values = %W(a p A P AB JM Hello hello pay)
      values << "" << " " << "   "
      values.each do |value|
        it "is invalid with #{value.inspect}" do
          subject.ampm = value
          subject.should have_at_least(1).errors_on(:ampm)
        end
      end
    end
  end

  describe '#date=' do
    it "adjusts the date to local time" do
      @utc = DateTime.parse("2010/05/06 16:00 PM UTC")
      @zone = ActiveSupport::TimeZone.new('Eastern Time (US & Canada)')
      subject.time_zone = @zone

      subject.date = @utc
      subject.hour.should == '12'
      subject.should be_pm
    end

    { DateTime.new(2010, 5, 6, 20, 1) => %W(2010 5 6 08 01 PM),
      DateTime.new(2010, 5, 6, 8, 59) => %W(2010 5 6 08 59 AM),
      DateTime.new(2010, 5, 6, 12, 1) => %W(2010 5 6 12 01 PM),
      DateTime.new(2010, 5, 6, 0, 59) => %W(2010 5 6 12 59 AM),
      Date.new(2010, 5, 6) => %W(2010 5 6 12 00 AM),
      Time.parse('2010/5/6 0:00 UTC') => %W(2010 5 6 12 00 AM)
    }.each do |date, (year, month, day, hour, minute, ampm)|
      context "with #{date}" do
        before(:each) do
          subject.date = date
        end

        it "sets year to #{year.to_i.inspect}" do
          subject.year.should == year.to_i
        end

        it "sets month to #{month.to_i.inspect}" do
          subject.month.should == month.to_i
        end

        it "sets day to #{day.to_i.inspect}" do
          subject.day.should == day.to_i
        end

        it "sets hour to #{hour.inspect}" do
          subject.hour.should == hour
        end

        it "sets minute to #{minute.inspect}" do
          subject.minute.should == minute
        end

        it "sets ampm to #{ampm.inspect}" do
          subject.ampm.should == ampm
        end

        it "converts to the supplied date" do
          subject.to_datetime.should == date
        end
      end
    end
  end

  describe '#time_zone_name' do
    it "returns the time zone's name" do
      subject.time_zone = mock('zone', :name => 'TZ')
      subject.time_zone.name.should == 'TZ'
    end
  end

  describe '#time_zone_name=' do
    before(:each) do
      @utc = ActiveSupport::TimeZone.new('UTC')
      @eastern = ActiveSupport::TimeZone.new('Eastern Time (US & Canada)')
      ActiveSupport::TimeZone.stub!(:new).and_return(@utc)
    end

    it "creates a new TimeZone from the value" do
      ActiveSupport::TimeZone.should_receive(:new).
        with('Eastern Time (US & Canada)').
        and_return(@eastern)

      subject.time_zone_name = 'Eastern Time (US & Canada)'
    end

    context 'valid time zone' do
      it "changes the time zone" do
        ActiveSupport::TimeZone.should_receive(:new).and_return(@eastern)

        lambda { subject.time_zone_name = 'Eastern Time (US & Canada)' }.should change(subject, :time_zone)
      end
    end

    context 'invalid time zone' do
      it "does not change the time zone" do
        lambda { subject.time_zone_name = 'WTF' }.should_not change(subject, :time_zone_name)
      end
    end
  end

  describe '#to_datetime' do
    context 'when valid' do
      before(:each) do
        @time = DateTime.new(2010, 5, 5, 20, 27)
      end

      subject { described_class.new(@time) }

      it "returns a DateTime created from the attributes, but adjusted to the time zone" do
        subject.to_datetime.should == subject.time_zone.utc_to_local(@time)
      end
    end

    context 'when invalid' do
      before(:each) do
        subject.hour = 25
      end

      it "returns nil" do
        subject.to_datetime.should be_nil
      end
    end
  end

  describe '#pm?' do
    %W(am Am AM aM a hello).each do |v|
      context "with #{v.inspect}" do
        before(:each) do
          subject.ampm = v
        end

        it "is false for #{v.inspect}" do
          subject.should_not be_pm
        end
      end
    end

    %W(pm Pm PM pM p).each do |v|
      context "with #{v.inspect}" do
        before(:each) do
          subject.ampm = v
        end

        it "is true for #{v.inspect}" do
          subject.should be_pm
        end
      end
    end
  end

  describe '#blank?' do
    it "is true if all the attributes are blank" do
      subject.should be_blank
    end

    [ :year, :month, :day, :hour, :minute ].each do |attr|
      it "is false if #{attr} has a value" do
        subject.send("#{attr}=", 1)
        subject.should_not be_blank
      end
    end
  end

  describe '#allow_blank?' do
    context 'when :allow_blank was true during creation' do
      subject { described_class.new(:allow_blank => true) }

      it "is true" do
        subject.should be_allow_blank
      end
    end

    context 'when :allow_blank was false during creation' do
      subject { described_class.new(:allow_blank => false) }

      it "is true" do
        subject.should_not be_allow_blank
      end
    end
  end

  describe '#month' do
    { 1 => 1,
      '1' => 1,
      'aaa' => 'aaa',
      :hello => :hello
    }.each do |value, expecting|
      context 'when month is set to #{value.inspect}' do
        before(:each) do
          subject.month = value
        end

        it "returns #{expecting}" do
          subject.month.should == expecting
        end
      end
    end
  end
end
