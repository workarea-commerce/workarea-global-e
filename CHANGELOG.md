Workarea Global E 1.0.0 (2019-08-22)
--------------------------------------------------------------------------------

*   Fix incorrect item price adjustment amounts

    GLOBALE-37
    Eric Pigeon

*   Save payment with journaled and write majority

    GLOBALE-31
    Eric Pigeon

*   Add GlobalE Order Id to Admin Search Text

    Update GlobalE orders to be search `jump_to`

    GLOBALE-32
    Eric Pigeon



Workarea Global E 1.0.0.beta.9 (2019-06-19)
--------------------------------------------------------------------------------

*   Move GlobalE domains to config

    Eric Pigeon

*   Remove domestic countries config

    Remove config for controlling what countries aren't operated by GlobalE
    and use new cookie

    GLOBALE-30
    Eric Pigeon



Workarea Global E 1.0.0.beta.8 (2019-06-07)
--------------------------------------------------------------------------------

*   Update Product.Attributes

    Change Attribute#name to the detail values and Attribute#code to the the
    key.
    Fix typo in GlobalE API URLs
    Eric Pigeon



Workarea Global E 1.0.0.beta.7 (2019-06-04)
--------------------------------------------------------------------------------

*   Handle discounts that only exist in GlobalE

    Shipping and Duties discounts only exist in GlobalE and don't have a
    corresponding discount in Workarea, handle when the original discount
    doens't exist and ignore them in analytics
    Eric Pigeon

*   Only show country execptions on Products#show

    only add country exceptions data tags to the main product on
    Products#show
    Eric Pigeon

*   Fix discounts overdiscounting fixed pricing orders

    In `Discount::ApplicationGroup#value` each discount is applied to the
    order then removed from the order to determine the total value of that
    group. This fixes a bug were the discounts weren't removing
    international adjustments when calculating `ApplicationGroup#value`

    GLOBALE-29
    Eric Pigeon

*   Change Order::Item#discounted_price_except_duties_and_taxes to discounted_price_for_customs

    Eric Pigeon

*   Add Catalog::Product#global_e_forbidden to the admin

    Eric Pigeon



Workarea Global E 1.0.0.beta.6 (2019-05-17)
--------------------------------------------------------------------------------

*   Fix broken tests

    Eric Pigeon



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



