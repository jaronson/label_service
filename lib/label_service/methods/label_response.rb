module LabelService
	class LabelResponse

		def self.get_label_image_dir
			base = LabelService::Base.new
			if base.config.label_image_directory
				base.config.label_image_directory	
			else
				defined?(RAILS_ROOT) ? File.join(RAILS_ROOT,"public","images","shipping_labels") : File.join(LABEL_SERVICE_ROOT,"shipping_labels")
			end
		end

		LABEL_IMAGE_DIR = get_label_image_dir

		attr_accessor :tracking_number, :encoded_image, :encoded_html_image, :image, :image_directory, :image_filename, :html_image

		def label_url
			self.tracking_number ? File.join("#{LABEL_IMAGE_DIR}","labels","show",self.image_filename) : nil
		end
	end
end
