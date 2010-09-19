module SemanticGap
  module DateTimeForm
    module Spec
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def it_has_datetime_fields_for(attr, options = Hash.new)
          attr_fields = "#{attr}_fields"

          describe "\##{attr_fields}" do
            context 'first call' do
              before(:each) do
                subject.send("#{attr}=", Time.now)
              end

              it "creates a datetime form initialized with the value @#{attr} and the options #{options.inspect}" do
                SemanticGap::DateTimeForm::Form.should_receive(:new).
                  with(subject.send(attr), options)

                subject.send(attr_fields)
              end

              it "returns the form" do
                SemanticGap::DateTimeForm::Form.should_receive(:new).and_return(:form)
                subject.send(attr_fields).should == :form
              end
            end

            context 'subsequent calls' do
              before(:each) do
                @form = subject.send(attr_fields)
              end

              it "does not create a new datetime form" do
                SemanticGap::DateTimeForm::Form.should_not_receive(:new)
                subject.send(attr_fields)
              end

              it "returns the form" do
                subject.send(attr_fields).should == @form
              end
            end
          end

          describe "\##{attr_fields}=" do
            it "updates the fields' attributes with the value" do
              @params = { :year => 2010, :month => 5, :day => 6 }
              subject.send(attr_fields).should_receive(:attributes=).with(@params)

              subject.send("#{attr_fields}=", @params)
            end

            context 'with valid fields' do
              it "updates @#{attr} to the fields' datetime" do
                @params = { :year => 2010, :month => 5, :day => 6, :hour => 12, :minute => 0, :ampm => 'PM' }
                
                lambda { subject.send("#{attr_fields}=", @params) }.
                  should change(subject, attr).to(DateTime.new(2010, 5, 6, 12, 0))
              end
            end

            context 'with invalid fields' do
              before(:each) do
                subject.send("#{attr}=", Time.now)
              end

              it "updates @#{attr} to nil" do
                lambda { subject.send("#{attr_fields}=", { :month => 13 } ) }.
                  should change(subject, attr).to(nil)
              end
            end
          end

          describe '#valid?' do
            context 'when #{attr_fields} are valid' do
              before(:each) do
                subject.send(attr_fields).stub!(:valid?).and_return(true)
              end

              it "does NOT add errors for #{attr}" do
                subject.should_not have(:any).errors_on(attr)
              end
            end

            context 'when #{attr_fields} are invalid' do
              before(:each) do
                subject.send(attr_fields).stub!(:valid?).and_return(false)
              end

              it "adds errors for :published_at" do
                subject.should have_at_least(1).error_on(attr)
              end
            end
          end

          describe '#save!' do
            context "when #{attr} is nil" do
              before(:each) do
                subject.send("#{attr}=", nil)
              end

              it "updates #{attr} with the #{attr_fields} datetime" do
                @time = DateTime.now
                subject.send(attr_fields).should_receive(:to_datetime).and_return(@time)
                subject.send(attr_fields).stub!(:valid?).and_return(true)

                lambda { subject.save! }.should change(subject, attr).to(@time)
              end
            end

            context "when #{attr} is not nil" do
              before(:each) do
                subject.send("#{attr}=", Time.now)
              end

              it "does NOT change #{attr}" do
                lambda { subject.save! }.should_not change(subject, attr)
              end
            end
          end
        end
      end
    end
  end
end
