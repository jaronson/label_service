module LabelService
	class Certification
		def self.certify 
			0.upto(4) do |i|
				a = ""
				r = LabelService::LabelRequest.new
				if i == 0
					r.insured_value = 999
					a = "hv_"	
				end
				r.post
				
				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{r.ship_accept.label.tracking_number}_#{a}ship_confirm_request.xml","w")
				f.puts(r.xml)
				f.close

				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{r.ship_accept.label.tracking_number}_#{a}ship_confirm_response.xml","w")
				f.puts(r.response_xml)
				f.close

				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{r.ship_accept.label.tracking_number}_#{a}ship_accept_request.xml","w")
				f.puts(r.ship_accept.xml)
				f.close

				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{r.ship_accept.label.tracking_number}_#{a}ship_accept_response.xml","w")
				f.puts(r.ship_accept.response_xml)
				f.close
			
			end

			tracking_numbers = ["1Z12345E0193075279","1Z12345E0390817264","1Z12345E0392508488","1Z12345E1290420899"]
			tracking_numbers.each do |n|
				v = LabelService::LabelRequest.void(n)
				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{n}_void_request.xml","w")
				f.puts v.to_xml
				f.close 

				f = File.new("#{LABEL_SERVICE_ROOT}/certification/#{n}_void_response.xml","w")
				f.puts v.response_xml
				f.close
			end
		end
	end
end
