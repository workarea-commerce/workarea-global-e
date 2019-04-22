Workarea.configure do |config|
  config.tender_types.prepend(:global_e_payment)
  config.order_status_calculators.unshift("Workarea::Order::Status::PendingGlobalEFraudCheck")
  config.payment_status_calculators.unshift(
    "Workarea::Payment::Status::PendingGlobalEFraudCheck",
    "Workarea::Payment::Status::GlobalEApproved"
  )
  config.fulfillment_status_calculators.unshift(
    "Workarea::Fulfillment::Status::Refunded",
    "Workarea::Fulfillment::Status::PartiallyRefunded"
  )

  config.global_e = ActiveSupport::Configurable::Configuration.new

  config.global_e.enabled = true
  config.global_e.javascript_source = nil
  config.global_e.css_source = nil
  config.global_e.merchant_guid = nil

  config.global_e.domestic_countries = ["US"]

  config.global_e.currencies = ["AFN", "DZD", "ARS", "AMD", "AWG", "AUD", "AZN",
    "BSD", "BHD", "THB", "PAB", "BBD", "BZD", "BMD", "BOB", "BRL", "BND", "BGN",
    "BIF", "CAD", "CVE", "KYD", "XOF", "XAF", "XPF", "CLP", "COP", "KMF", "CDF",
    "BAM", "NIO", "CRC", "HRK", "CUP", "CZK", "GMD", "DKK", "MKD", "DJF", "STD",
    "DOP", "VND", "XCD", "EGP", "ETB", "EUR", "FKP", "FJD", "HUF", "GHS", "HTG",
    "PYG", "GNF", "GYD", "HKD", "UAH", "ISK", "INR", "IRR", "IQD", "ILS", "JMD",
    "JOD", "KES", "PGK", "LAK", "KWD", "MWK", "AOA", "MMK", "GEL", "LBP", "ALL",
    "HNL", "SLL", "LRD", "LYD", "SZL", "LSL", "MGA", "MYR", "MUR", "MXN", "MDL",
    "MAD", "MZN", "NGN", "ERN", "NAD", "NPR", "ANG", "BYN", "RON", "TWD", "NZD",
    "BTN", "KPW", "NOK", "MRO", "TOP", "PKR", "MOP", "UYU", "PHP", "GBP", "BWP",
    "QAR", "GTQ", "ZAR", "OMR", "KHR", "MVR", "IDR", "RUB", "RWF", "SHP", "SAR",
    "RSD", "SCR", "SGD", "PEN", "SBD", "KGS", "SOS", "TJS", "LKR", "SDG", "SRD",
    "SEK", "CHF", "SYP", "BDT", "WST", "TZS", "KZT", "TTD", "MNT", "TND", "TRY",
    "TMT", "AED", "UGX", "USD", "UZS", "VUV", "KRW", "YER", "JPY", "CNY", "ZMW",
    "ZWL", "PLN",
  ]

  config.global_e.countries = ["AL", "DZ", "AS", "AD", "AI", "AG", "AR", "AM",
    "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM",
    "BT", "BO", "BQ", "BA", "BW", "BR", "VG", "BN", "BG", "KH", "CA", "CV", "KY",
    "CL", "CN", "CO", "KM", "CK", "CR", "HR", "CU", "CW", "CY", "CZ", "DK", "DJ",
    "DM", "DO", "TP", "EC", "EG", "SV", "ER", "EE", "ET", "MK", "FK", "FO", "FJ",
    "FI", "FR", "GF", "PF", "TF", "GE", "DE", "GI", "GR", "GL", "GD", "GP", "GU",
    "GT", "GG", "GN", "GW", "GY", "HT", "HN", "HK", "HU", "IS", "IN", "ID", "IQ",
    "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KR", "KW",
    "KG", "LA", "LV", "LB", "LS", "LY", "LI", "LT", "LU", "MO", "MG", "MW", "MY",
    "MV", "MT", "MH", "MQ", "MR", "MU", "MX", "FM", "MD", "MC", "MN", "ME", "MS",
    "MA", "MZ", "NA", "NR", "NP", "NL", "AN", "NC", "NZ", "NI", "NG", "NU", "MP",
    "NO", "OM", "PK", "PW", "PA", "PG", "PY", "PE", "PH", "PL", "PT", "PR", "QA",
    "RE", "RO", "RU", "KN", "LC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SG",
    "SK", "SI", "SB", "ZA", "ES", "LK", "BL", "MF", "SD", "SR", "SZ", "SE", "CH",
    "TW", "TZ", "TH", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UA", "AE", "GB",
    "US", "UY", "UZ", "VU", "VA", "VE", "VN", "VI", "WF", "ZM", "ZW"
  ]

  config.global_e.shipping_discount_types = ["Workarea::Pricing::Discount::Shipping"]
  config.global_e.free_gift_discount_types = ["Workarea::Pricing::Discount::FreeGift"]
end
