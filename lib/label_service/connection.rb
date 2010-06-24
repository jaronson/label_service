module LabelService
	class Connection < ActiveResource::Connection
		def logger
			Base.logger
		end

    private
      # Makes request to remote service.
      def request(method, path, *arguments)
        logger.info "#{method.to_s.upcase} #{site.scheme}://#{site.host}:#{site.port}#{path}" 
        result = nil
        ms = Benchmark.ms { result = http.send(method, path, *arguments) }
        logger.info "--> %d %s (%d %.0fms)" % [result.code, result.message, result.body ? result.body.length : 0, ms] 
        handle_response(result)
      rescue Timeout::Error => e
        raise TimeoutError.new(e.message)
      end
	end
end
