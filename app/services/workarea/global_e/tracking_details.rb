module Workarea
  module GlobalE
    class TrackingDetails
      attr_reader :tracking_number

      def initialize(tracking_number:)
        @tracking_number = tracking_number
      end

      def as_json(*)
        { TrackingNumber: tracking_number }
      end

      # The tracking number as the shipper has specified.
      #
      # @return [String]
      #
      def tracking_number
        @tracking_number
      end
    end
  end
end
