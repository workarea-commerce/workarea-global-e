module Workarea
  module GlobalE
    module Api
      class SendOrderToMerchant::SaveUser
        attr_reader :user_id, :shipping_details, :billing_details, :culture_code

        def self.perform!(user_id, shipping_details:, billing_details:, culture_code:)
          new(
            user_id,
            shipping_details: shipping_details,
            billing_details: billing_details,
            culture_code: culture_code
          ).perform!
        end

        # @param user_id [String, BSON::ObjectId]
        # @param shipping_details [Workarea::GlobalE::Merchant::CustomerDetails]
        # @param billing_details [Workarea::GlobalE::Merchant::CustomerDetails]
        # @param culture_code [String]
        #
        def initialize(user_id, shipping_details:, billing_details:, culture_code:)
          @user_id = user_id
          @shipping_details = shipping_details
          @billing_details = billing_details
          @culture_code = culture_code
        end

        def perform!
          return if user.nil?
          upsert_address(shipping_details)
          upsert_address(billing_details)
          user.global_e_culture_code = culture_code

          user.save
        end

        private

          def user
            @user ||= Workarea::User.find user_id rescue nil
          end

          # @param customer_details [Workarea::GlobalE::Merchant::CustomerDetails]
          #
          def upsert_address(customer_details)
            existing_address = user.addresses.detect do |user_address|
              user_address.id.to_s == customer_details.address_book_id.to_s
            end

            if existing_address.present?
              existing_address.attributes = customer_details.workarea_address_attributes
            else
              user.addresses.build customer_details.workarea_address_attributes
            end
          end
      end
    end
  end
end
