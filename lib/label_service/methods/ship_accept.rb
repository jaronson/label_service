module LabelService
	class ShipAccept < LabelService::Base
		attr_accessor :shipment_digest, :zip_code
		attr_reader :response_xml, :label

		def initialize(attrs = {})
			self.site = "https://wwwcie.ups.com/"
			self.request_action = "ShipAccept"
			self.request_name = "ShipmentAcceptRequest"
			super(attrs)
		end

		def handle_method_response(text)
			begin
				@response_xml = text
				@label = LabelResponse.new
				doc = XML::Parser.string(text).parse
				@label.tracking_number = doc.find_first("//ShipmentAcceptResponse/ShipmentResults/PackageResults/TrackingNumber").inner_xml
				@label.encoded_image = doc.find_first("//ShipmentAcceptResponse/ShipmentResults/PackageResults/LabelImage/GraphicImage").inner_xml
				@label.encoded_html_image = doc.find_first("//ShipmentAcceptResponse/ShipmentResults/PackageResults/LabelImage/HTMLImage").inner_xml

				@label.image_directory = get_image_directory
				@label.image_filename = File.join(@label.image_directory,"#{@label.tracking_number}.gif")
				@label.image = File.new(@label.image_filename,"w+")
				@label.image.write(Base64.decode64(@label.encoded_image))
				@label.image.close

				@label.html_image = File.new(File.join(@label.image_directory, "#{@label.tracking_number}-SIZING.html"), "w+")
				@label.html_image.write(Base64.decode64(@label.encoded_html_image))
				@label.html_image.close
				@label
			rescue Errno::ENOENT 
				raise "Are you sure the label directory exists at #{LabelResponse::LABEL_IMAGE_DIR} ?\n#{$!}"
			rescue
				raise $!
			end
		end

		def get_image_directory
			image_dir = File.join(LabelResponse::LABEL_IMAGE_DIR, self.zip_code.to_s[0,3])
			unless File.exists?(image_dir) && File.directory?(image_dir)
				FileUtils.mkdir(image_dir)
			end
			return image_dir
		end
	end
end
