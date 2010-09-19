module SemanticGap
  module DateTimeForm
    module ActiveRecordMixin
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def datetime_fields_for(attr, options = Hash.new)
          method_name = "#{attr}_fields"
          define_method(method_name) do
            fields = instance_variable_get("@#{method_name}")
            unless fields
              instance_variable_set("@#{method_name}", Form.new(send(attr), options))
              
            end
            instance_variable_get("@#{method_name}")
          end

          define_method("#{method_name}=") do |params|
            fields = send(method_name)
            fields.attributes = params
            send("#{attr}=", fields.to_datetime)
          end

          define_method("validate_#{method_name}") do
            form = send(method_name)
            errors.add(attr, "is invalid") unless form.valid?
          end

          validate "validate_#{method_name}"

          define_method("update_#{attr}") do
            send("#{attr}=", send(method_name).to_datetime) if send(attr).nil?
          end

          before_save "update_#{attr}"
        end
      end
    end
  end
end
