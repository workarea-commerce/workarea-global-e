# Workarea GlobalE

GlobalE in an international checkout provider.

## Configuration
```yaml
Workarea.configure do |config|
  config.global_e.javascript_source = YOUR GLOBALE JAVASCRIPT URL
  config.global_e.css_source = YOUR GLOBALE CSS URL
  config.global_e.merchant_guid = YOUR GLOBALE MERCHANT ID
end
```

## Views
GlobalE requires data tags on multiple views on Storefront.  The plugin
overrides the following views:
* `storefront/cart_items/create.html.haml`
* `storefront/cart/_pricing.html.haml`
* `storefront/cart/show.html.haml`
* `storefront/products/pricing.html.haml`
* `storefront/uses/orders/_summary.html.haml`


## Fraud
GlobalE handles the liability of fraud for their orders; after an order is placed via GlobalE
it will be Pending GlobalE Faud until GlobalE clears the payment.  `Order#place` callbacks aren't fired
until after the order is cleared for fraud.  GlobalE will cancel the order if it it's fraudulent.

Refer to the views in the plugin for required data tags.

## Workarea Platform Documentation

See [http://developer.weblinc.com](http://developer.weblinc.com) for Workarea platform documentation.

## Copyright & Licensing

Copyright WebLinc 2019. All rights reserved.

For licensing, contact sales@workarea.com.
