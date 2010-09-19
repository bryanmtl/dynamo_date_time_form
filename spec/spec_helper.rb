RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
module Rails
  module VERSION
    STRING = '0.0.1'
  end
end

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'vendor', 'active_form', 'lib'))

require 'rubygems'
require 'active_record'
require 'active_form'
require 'action_controller'
require 'action_view'
require 'semanticgap_date_time_form'

require 'spec'
require 'spec/rails'
