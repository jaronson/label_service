module LabelService
	class Void < LabelService::Base
		attr_accessor :shipment_number, :tracking_numbers
		attr_reader :response_xml

		def initialize(attrs = {})
			self.site = "https://wwwcie.ups.com/"
			self.request_action = "Void"
			self.request_name = "Void"
			super attrs
		end

		def tracking_numbers_array(builder)
			if self.tracking_numbers
				self.tracking_numbers.each do |ref|
					builder.ReferenceNumber{|b| 
						b.Code ref[:code] if ref[:code]
						b.Value ref[:value] if ref[:value]
					}
				end
			end
			return builder
		end

		def handle_method_response(text)
			@response_xml = text
			puts text
		end
	end
end
