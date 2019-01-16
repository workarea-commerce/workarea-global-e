module Workarea
  module GlobalE
    class Attribute

      def initialize(code: nil, name: nil, type_code: nil)
        @code = code
        @name = name
        @type_code = type_code
      end

      def as_json(*_args)
        {
          AttributeCode: attribute_code,
          Name: name,
          AttributeTypeCode: attribute_type_code
        }.compact
      end

      # Custom attribute code denoting a Merchant-specific attribute such
      # as Size, Color, etc. (to be mapped on Global-e side)
      #
      # @return [String]
      #
      def attribute_code
        @code
      end

      # Attribute name
      #
      # @return [String]
      #
      def name
        @name
      end

      # Code used to identify the attribute type on the Merchant’s site such
      # as “size” for Size, “color” for Color, etc.
      # (to be mapped on Global-e side)
      def attribute_type_code
        @type_code
      end
    end
  end
end
