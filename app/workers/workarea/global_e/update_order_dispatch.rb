module Workarea
  module GlobalE
    class UpdateOrderDispatch
      include Sidekiq::Worker

      DOMAINS = {
        "qa" => "https://connect-qa.bglobale.com",
        "qa-int" => "https://connect.bglobale.com/",
        "staging" => "ttps://connect2.bglobale.com",
        "production" => "https://api.global-e.com"
      }

      def perform(id, tracking_number)
        domain = DOMAINS[GlobalE.environment]
        path = "/Order/UpdateOrderDispatchV2?merchantGUID=#{GlobalE.merchant_guid}"

        dispatch = UpdateOrderDispatchRequest.new(id, tracking_number: tracking_number)
        uri = URI("#{domain}#{path}")

        http = Net::HTTP.new(uri.host, uri.port).tap do |net_http|
          net_http.use_ssl = true
        end

        post = Net::HTTP::Post.new(path).tap do |request|
          request['Content-Type'] = 'application/json'
          request.body = dispatch.to_json
        end

        response = http.request(post)

        raise response.body unless response.is_a? Net::HTTPSuccess
      end
    end
  end
end
