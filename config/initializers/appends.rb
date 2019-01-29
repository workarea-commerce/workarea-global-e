Workarea.append_partials(
  'storefront.document_head',
  'workarea/storefront/global_e/head'
)

Workarea.append_partials(
  'storefront.footer_help',
  'workarea/storefront/global_e/country_picker'
)

Workarea.append_javascripts(
  "storefront.config",
  "workarea/storefront/global_e/global_e_config"
)

Workarea.append_javascripts(
  "storefront.modules",
  "workarea/storefront/global_e/modules/suppress_price_ranges"
)

Workarea.append_partials(
  'admin.order_cards',
  'workarea/admin/orders/global_e'
)
