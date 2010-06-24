module LabelService
	class LabelRequest < ShipConfirm
    def self.void(tracking_number)
      request = LabelService::Void.new(:shipment_number => tracking_number)
      request.post	
      request
    end
	end
end
