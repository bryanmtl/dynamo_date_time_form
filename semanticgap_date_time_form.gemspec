Gem::Specification.new do |s|
  s.name = "semanticgap_date_time_form"
  s.version = "0.1.3"

  s.authors = ["SemanticGap", "Dynamo"]
  s.date = "2010-09-18"
  s.description = "An improved date time selector for Rails."
  s.email = "info@semanticgap.com"
  s.add_dependency "nayutaya-active-form"
  s.files = [ "./lib/semanticgap_date_time_form/active_record_mixin.rb",
              "./lib/semanticgap_date_time_form/form.rb",
              "./lib/semanticgap_date_time_form/form_builder_mixin.rb",
              "./lib/semanticgap_date_time_form/spec.rb",
              "./lib/semanticgap_date_time_form.rb",
              "./MIT-LICENSE",
              "./public/stylesheets/semanticgap_date_time_form.css",
              "./rails/init.rb",
              "./rails/install.rb",
              "./rails/uninstall.rb",
              "./Rakefile",
              "./README",
              "./semanticgap_date_time_form.gemspec",
              "./semanticgap_date_time_form.gemspec~",
              "./spec/application.rb",
              "./spec/integration/post_spec.rb",
              "./spec/spec_helper.rb",
              "./spec/unit/active_record_mixin_spec.rb",
              "./spec/unit/form_builder_mixin_spec.rb",
              "./spec/unit/form_spec.rb",
              "./tasks/semanticgap_datetime_fields_tasks.rake" ]
  s.homepage = "http://github.com/bryanmtl/dynamo_date_time_form
"
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = "Improved date time selector"
end
