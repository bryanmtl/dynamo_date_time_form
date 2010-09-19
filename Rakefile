require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

require 'spec/rake/spectask'

desc "Run the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = [ '-fprogress', '-fhtml:doc/spec.html' ]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run the specs with rcov"
  Spec::Rake::SpecTask.new(:coverage) do |t|
    t.spec_opts = [ '-fprogress', '-fhtml:doc/spec.html' ]
    t.rcov = true
    t.rcov_opts = [ '--rails', '--exclude', 'spec/*,gems/*' ]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end

desc 'Generate documentation for the semanticgap_datetime_fields plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SemanticgapDatetimeFields'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
