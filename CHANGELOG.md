Workarea Global E 1.0.0.beta.5 (2019-05-16)
--------------------------------------------------------------------------------

*   QA feedback

    Fix DiveredQuantity -> DilveryQuantity
    Add `name` in Product.Attributes
    Add missing data tags on `cart_items/create`
    Add data tag to GE Checkout view
    Add config for controlling GE environment
    Send only required fields in Parcel.Product
    Eric Pigeon



Workarea Global E 1.0.0.beta.4 (2019-05-13)
--------------------------------------------------------------------------------

*   Feedback from GlobalE QA

    Price order before redirect to ensure fixed pricing is cleared out if
    needed
    Set gift cards as forbidden
    Only send GlobalE orders to GlobalE in OrderUpdateDispatch
    Add data tags to `cart_items/create.html.haml`
    Add fixed pricing tags to unit prices in `carts/show.html.haml`

    GLOBALE-27
    Eric Pigeon



Workarea Global E 1.0.0.beta.3 (2019-05-01)
--------------------------------------------------------------------------------

*   Implement OrderUpdateDispatch

    GLOBALE-21
    Eric Pigeon

*   Country Exceptions Support

    Country exceptions allow certain product's to have a minimum VAT rate,
    or be restricted from checkout.

    GLOBALE-26
    Eric Pigeon

*   Add Fixed Price Support

    Fixed prices allow the merchant to target specific countries, or
    currencies (like the Eurozone) to localize their prices instead of
    dynamic conversion.

    GLOBALE-25
    Eric Pigeon



Workarea Global E 1.0.0.beta.2 (2019-04-04)
--------------------------------------------------------------------------------

*   Add new fields from GlobalE

    `Order#contains_clearance_fees_price`
    `Order::Item#discounted_price_except_duties_and_taxes`
    `Order::Item#generic_hs_code`
    Eric Pigeon



Workarea Global E 1.0.0.beta.1 (2019-04-03)
--------------------------------------------------------------------------------

*   Beta 1.0.0 release

    Update discount display and CheckoutCartInfo response to match, and fix
    issues with discount analytics
    Eric Pigeon



Workarea Global E 1.0.0.alpha.1 (2019-03-28)
--------------------------------------------------------------------------------

*   Alpha 1.0.0 release

    GlobalE's smart cross border solution enables international customers to
    shop in a localized experience.
    Eric Pigeon



