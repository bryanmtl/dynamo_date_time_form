require 'active_form'

module SemanticGap
  module DateTimeForm
    class Form < ActiveForm
      def initialize(*args)
        super()

        options = args.extract_options!
        date = args.first

        @time_zone = options.fetch(:time_zone) { Time.zone || ActiveSupport::TimeZone.new('UTC') }
        @allow_blank = options.fetch(:allow_blank) { false }

        self.date = date if date.respond_to?(:strftime)
      end

      def date=(d)
        d = time_zone.utc_to_local(d.to_datetime.utc)

        self.attributes = {
          :year => d.year, :month => d.month, :day => d.day,
          :hour => d.strftime("%I"), :minute => d.strftime("%M"), :ampm => d.strftime("%p")
        }
      end

      attr_accessor :year, :month, :day, :hour, :minute, :ampm, :time_zone

      validate :validate_time
      validate :validate_date

      def month
        if @month.kind_of?(String) && @month =~ /\d+/
          @month.to_i
        else
          @month
        end
      end

      def time_zone_name
        time_zone.name
      end

      def time_zone_name=(str)
        tz = ActiveSupport::TimeZone.new(str)

        if tz
          self.time_zone = tz
          time_zone_name
        end
      end

      def allow_blank?
        @allow_blank
      end

      def validate_time
        return if allow_blank? && time_blank?

        errors.add(:hour, "is invalid") unless hour.to_s =~ /\d+/ && (0..23).include?(hour.to_i)
        errors.add(:minute, "is invalid") unless minute.to_s =~ /\d+/ && (0..59).include?(minute.to_i)
        errors.add(:ampm, "must be AM or PM") unless %W(AM PM am pm).include?(ampm)
      end

      def validate_date
        return if allow_blank? && date_blank?

        errors.add(:year, "#{year} is not a valid year") unless year.to_s =~ /\d+/
        errors.add(:month, "#{month} is not a valid month") unless (1..12).include?(month.to_i)
        errors.add(:day, "#{day} is not a valid day") unless day.to_s =~ /\d+/ && (1..31).include?(day.to_i)

        if errors[:month].blank? && errors[:month].blank?
          begin
            build_datetime
          rescue ArgumentError
            errors.add(:day, "is invalid")
          end
        end
      end

      def pm?
        ampm[0, 1].downcase == 'p' unless ampm.blank?
      end

      def blank?
        time_blank? && date_blank?
      end

      def to_datetime
        return nil if (allow_blank? && blank?) || !valid?

        time_zone.local_to_utc(build_datetime)
      end

      private

      def build_datetime
        DateTime.new(year.to_i, month, day.to_i, adjusted_hour, minute.to_i)
      end

      def adjusted_hour
        h = hour.to_i
        h = h + 12 if h < 12 && pm?
        h = 0 if h == 12 && !pm?
        h
      end

      def time_blank?
        hour.blank? && minute.blank?
      end

      def date_blank?
        year.blank? && @month.blank? && day.blank?
      end
    end
  end
end
