require 'semanticgap_date_time_form/form'
require 'semanticgap_date_time_form/active_record_mixin'
require 'semanticgap_date_time_form/form_builder_mixin'

ActionView::Helpers::FormBuilder.send(:include, SemanticGap::DateTimeForm::FormBuilderMixin)
ActiveRecord::Base.send(:include, SemanticGap::DateTimeForm::ActiveRecordMixin)
