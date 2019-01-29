module Workarea
  module GlobalE
    module Merchant
      class ParcelTracking

        # Tracking number used by the selected international shipping method
        # for this parcel.
        #
        # @return [String]
        #
        def tracking_number
        end

        # Full tracking URL including ParcelTrackingNumber used by the selected
        # international shipping method for this parcel.
        #
        # @return [String]
        #
        def tracking_url
        end

        # Parcel code
        #
        # @return [String]
        #
        def code
        end
      end
    end
  end
end
