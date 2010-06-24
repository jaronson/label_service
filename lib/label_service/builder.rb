module LabelService
	class Builder < Builder::XmlMarkup
		
		def access_request!(obj)
			self.instruct!
			self.AccessRequest("xml:lang" => "en-US"){ |b|
				b.AccessLicenseNumber(Base.config.service_license_number)
				b.UserId(Base.config.service_username)
				b.Password(Base.config.service_password)
			}
		end
	end
end
