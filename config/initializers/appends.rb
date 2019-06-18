Workarea.append_partials(
  'storefront.document_head',
  'workarea/storefront/global_e/head'
)

Workarea.append_partials(
  'storefront.footer_help',
  'workarea/storefront/global_e/country_picker'
)

Workarea.append_javascripts(
  "storefront.modules",
  "workarea/storefront/global_e/modules/suppress_price_ranges"
)

if Rails.env.test? || Rails.env.development?
  Workarea.append_javascripts(
    "storefront.modules",
    "workarea/storefront/global_e/modules/checkout_info_validator"
  )
end

Workarea.append_partials(
  'admin.order_cards',
  'workarea/admin/orders/global_e'
)

Workarea.append_partials(
  'admin.catalog_product_cards',
  'workarea/admin/catalog_products/country_exceptions_card'
)

Workarea.append_partials(
  'storefront.product_details',
  'workarea/storefront/products/restricted_item_text'
)

Workarea.append_partials(
  'admin.product_attributes_card',
  'workarea/admin/catalog_products/global_e_attributes'
)

Workarea.append_partials(
  'admin.product_fields',
  'workarea/admin/catalog_products/global_e_fields'
)
