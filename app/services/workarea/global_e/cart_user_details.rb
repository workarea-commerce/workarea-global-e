module Workarea
  module GlobalE
    class CartUserDetails
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(*args)
        {
          UserId: user_id,
          AddressDetails: address_details
        }.compact
      end

      # Internal User identifier on the Merchant’s site.
      #
      # @return [String]
      #
      def user_id
        user.id.to_s
      end

      # All available addresses taken from the registered customer address book
      #
      # @return [Array<Workarea::GlobalE::AddressDetails>]
      #
      def address_details
        @address_details ||= user.addresses.map { |address| AddressDetails.new user, address }
      end
    end
  end
end
