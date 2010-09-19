module SemanticGap
  module DateTimeForm
    module FormBuilderMixin
      def datetime_form(attr, value = nil)
        value ||= @object.try(datetime_param(attr))
        form = fields_for(datetime_param(attr), value) do |f|
          f.text_field(:year, :size => 4) + "/" +
            @template.select_month(value, :prefix => f.object_name, :include_blank => value.allow_blank?) + "/" +
            f.text_field(:day, :size => 2) + "&mdash;" +
            f.text_field(:hour, :size => 2) + ":" +
            f.text_field(:minute, :size => 2) +
            f.select(:ampm, %W(AM PM)) +
            @template.content_tag('span', value.time_zone.name, :class => 'timezone')
            # @template.time_zone_select(f.object_name, :time_zone_name, ActiveSupport::TimeZone.us_zones, :default => Time.zone.name)
        end

        raw(@template.content_tag('div', form, :class => 'sg-datetime-form'))
      end

      private
      def datetime_param(attr)
        "#{attr}_fields"
      end
    end
  end
end
