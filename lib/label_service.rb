$:.unshift(File.dirname(__FILE__))

begin
   require 'rubygems'
rescue LoadError
   nil
end

LABEL_SERVICE_ROOT = "#{File.dirname(__FILE__)}/label_service" unless defined?(LABEL_SERVICE_ROOT)

require 'libxml'
require 'builder'
require 'rexml/document'
require 'yaml'
require 'base64'
require 'ostruct'

require 'active_support'
require 'active_resource'

require 'label_service/connection'
require 'label_service/builder'
require 'label_service/base'
require 'label_service/certification'

require 'label_service/methods/ship_confirm'
require 'label_service/methods/ship_accept'
require 'label_service/methods/label_request'
require 'label_service/methods/label_response'
require 'label_service/methods/void'
