module LabelService
	class ShipConfirm < LabelService::Base
		attr_accessor( 
			:recipient_company,
			:recipient_name,
			:recipient_phone,
			:recipient_email,
			:recipient_address_1,
			:recipient_city,
			:recipient_state,
			:recipient_zip_code,
			:recipient_country,

			:sender_company,
			:sender_name,
			:sender_phone,
			:sender_email,
			:sender_address_1,
			:sender_city,
			:sender_state,
			:sender_zip_code,
			:sender_country,

      :description,

			:weight,
			:package_total,
			:packaging_type,
			:service_type_code,
			:service_type_description,
			:recipient_date,
			:dropoff_type,
			:currency_code,

			:reference_numbers,
			:insured_value
		)

		attr_reader :response_xml, :response, :ship_accept

		def initialize(attrs = {})
			self.site = "https://wwwcie.ups.com/"
			self.request_action = "ShipConfirm"
			self.request_name = "ShipmentConfirmRequest"
			super(attrs)
		end

    def return_service=(service)
      @return_service = service
    end

    def return_service
      return @return_service unless @return_service.nil?
      if self.sender_country
        if self.sender_country == 'CA'
          @return_service = '9' 
        end
      end 
      @return_service
    end 

		def reference_numbers_array(builder)
			if self.reference_numbers
				self.reference_numbers.each do |ref|
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
			doc = XML::Parser.string(text).parse
			shipment_digest = doc.find_first("//ShipmentConfirmResponse/ShipmentDigest").inner_xml
			@ship_accept= ShipAccept.new(:shipment_digest => shipment_digest, :zip_code => self.sender_zip_code)
			@ship_accept.request
			@response = @ship_accept
		end	

		def void!
			if @response
			end
		end

		protected
			def validate
				super
				required = [
          :recipient_company,:recipient_name,:recipient_phone,:recipient_email,:recipient_address_1,
          :recipient_city,:recipient_state,:recipient_zip_code,:recipient_country,:sender_company,
          :sender_name,:sender_phone,:sender_email,:sender_address_1,:sender_city,:sender_state,
          :sender_zip_code,:sender_country,:weight
        ]
				required.each do |req|
					if self.send(req).nil?
						self.errors[req] = "is required" unless self.errors.include?(req)
					end
				end
				errors.size > 0 ? false : true
			end
	end
end
