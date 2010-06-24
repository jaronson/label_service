module LabelService
	class LabelServiceError < StandardError; end
	class LabelServiceRequestError < LabelServiceError; end

	class Base
		include LibXML
		# Class accessors
		cattr_accessor :config, :logger
	
		class << self
			protected
			# The config object is class variable, rather than an
			# instance variable, mainly in order that Builder
			# can access it
			# these values are set in the label_service.yml
			def load_config
				if defined? RAILS_ROOT
					config_path = File.join(RAILS_ROOT,"config","label_service.yml")
					#warn "We're riding on Rails, expecting LabelService config file to be located at: #{config_path}"
				else
					config_path = File.join(LABEL_SERVICE_ROOT,"../","label_service.yml")
					warn "We're not riding on Rails, expecting LabelService config file to be located at: #{config_path}"
				end
				
				if File.exists?(config_path)
					config_hash = YAML.load_file(config_path)
					self.config = OpenStruct.new(config_hash)
				else
					raise LabelServiceError, "No LabelService config file found!"
				end
			end

			def load_logger
				self.logger = defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(File.join(LABEL_SERVICE_ROOT,'log','label_service.log'))
			end
		end

		# Load the config file and logger
		load_config
		load_logger
		
		# Instance methods
		attr_accessor :site, :request_action, :request_name, :errors, :builder, :xml

		# Provides an AR-like interface for object instantiation
		# pass this a hash of attributes 
		def initialize(attributes = {})
			load(attributes)
		end
		

		# Much like AR, except that we:
		# 1. Don't have a database
		# 2. Want to include our config values
		# Default values can be set in label_service.yml
		def load(attributes)
			raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
			attributes.each do |key, value|
				self.send("#{key}=", value)
			end
			self.class.config.instance_values["table"].each do |k,v|
				m = k.to_sym
				self.send("#{m.to_s}=",v) if self.respond_to?(m) && self.send(m).nil?
			end
			self
		end

		# Creates XML to send to the service provider
		# since there's a specified heirarchy for each request method
		# we use the method YAML file to map our instance values
		# to the service's required XML
		def to_xml(options = {}) 
			@xml = ""
			@builder = Builder.new( :target => @xml, :indent => 4 )
			@builder.access_request!(self) unless !options[:access_request].nil? && !options[:access_request]
			@builder.instruct! unless !options[:instruct].nil? && !options[:instruct]
			
			# load this class's YAML file
			map = YAML.load_file("#{LABEL_SERVICE_ROOT}/methods/#{self.request_action.underscore}.yml")

			# this is in order to provide default and other values
			to_v = lambda do |value|
				return value.gsub("'","") if value =~ /^'(.*)'$/ # it's string literal
				m = value.to_sym
				return self.send(m) if self.respond_to?(m) && !self.send(m).nil? # it's an instance method
				return self.class.config.send(m) if self.class.config.respond_to?(m) && !self.class.config.send(m).nil? # it's a config method
				return nil
			end

			# recurse!
			to_x = lambda do |key, value| 
				el = key.camelize.to_sym
        next if el == :ReturnService and to_v.call(:return_service).nil?
				case value
					when String then @builder.__send__(el, to_v.call(value))
					when Hash then @builder.__send__(el){|b| 
            value.each(&to_x)
          }
					when Array then @builder = self.send("#{key}_array", @builder)
				end
			end

			# loop through map and build xml
			map.each(&to_x) 
			@xml
		end

		# Interface with LabelService::Connection
		# which is just ActiveResource::Connection
		def connection(refresh = false)
			@connection = Connection.new(self.site) 
		end

		# Alias for request
		def post
			request
		end

		# Send it on to UPS
		def request 
			if self.valid?
				path = "/#{Base.config.api_path}/#{self.request_action}"
				connection.post(path, self.to_xml).tap do |response|
					return handle_response(response)
				end
			else
				return false
			end
		end

		def handle_response(response)
			begin
				handle_method_response(response.body)
			rescue
				handle_error_response(response.body)
			end
		end

		def handle_error_response(text)
			doc = REXML::Document.new(text)
      error = REXML::XPath.first(doc, '//*/Response/Error')
   		unless !error 
				severity = REXML::XPath.first(error, '//ErrorSeverity').text
				code = REXML::XPath.first(error, '//ErrorCode').text
				description = REXML::XPath.first(error, '//ErrorDescription').text
				raise LabelServiceRequestError, "#{severity} Error ##{code}: #{description}"
			else
				raise $!
			end
		end

		def valid?
			validate
		end

		protected
		def validate
			self.errors = {}
		end
	end
end
