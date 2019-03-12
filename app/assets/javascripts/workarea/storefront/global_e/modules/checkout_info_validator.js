WORKAREA.registerModule('globalECheckoutInfoValidator', (function () {
    var cartToken = function() {
            return WORKAREA.cookie.read("GlobalECartId");
        },

        checkoutInfo = function() {
            return $.getJSON(WORKAREA.routes.storefront.globalECheckoutCartInfoPath({cartToken: cartToken()}));
        },

        verifyProductPrices = function(product, discounts) {
            var productContainer = $("[data-ge-basket-cartitemid='" + product.CartItemId + "']"),
                salePrice, listPrice, subtotalPrice, totalPrice;

            assertDom(productContainer, "Missing product container for " + product.CartItemId);

            if (!_.isUndefined(productContainer.data('geBasketFreegift'))) {
                return;
            }

            salePrice = $("[data-ge-basket-productsaleprice]", productContainer);
            listPrice = $("[data-ge-basket-productlistprice]", productContainer);
            subtotalPrice = $("[data-ge-basket-productsubtotalprice]", productContainer);
            totalPrice = $("[data-ge-basket-producttotalprice]", productContainer);

            assertDom(salePrice, "Missing sale price for " + product.Name + " : " + product.CartItemId);
            assertPrice(salePrice, product.OriginalSalePrice);

            assertDom(totalPrice, "Missing total price for " + product.Name + " : " + product.CartItemId);

            if (product.OriginalListPrice === product.OriginalSalePrice) {
                refuteDom(listPrice, "Expected not to find list price for " + product.Name + " : " + product.CartItemId);
            } else {
                assertDom(listPrice, "Expected to find list price for " + product.Name + " : " + product.CartItemId);
                assertPrice(listPrice, product.OriginalListPrice);
            }

            _.forEach(productDiscounts(product.CartItemId, discounts), verifyProductDiscount);
            if (productHasDiscounts(product.CartItemId, discounts)) {
                assertDom(subtotalPrice, "Missing subtotalPrice " + product.Name + " : " + product.CartItemId);
                assertPrice(subtotalPrice, product.OriginalSalePrice * product.OrderedQuantity);
            } else {
                refuteDom(subtotalPrice, "Expected not to find subtotalPrice for " + product.Name + " : " + product.CartItemId);
            }
        },

        productDiscounts = function(cartItemId, discounts) {
            return _.filter(discounts, { "ProductCartItemId": cartItemId });
        },

        verifyProductDiscount = function(discount) {
            var discountPrice = $("[data-ge-basket-productdiscountsprice='" + discount.DiscountCode + "']");

            assertDom(discountPrice, "Expected to find discount " + discount.name + " : " + discount.DiscountCode);
            assertPrice(discountPrice, discount.OriginalDiscountValue);
        },

        productHasDiscounts = function(cartItemId, discounts) {
            return !_.isUndefined(_.find(discounts, { "ProductCartItemId": cartItemId }));
        },

        verifyOrderPrices = function(products, discounts) {
            var subtotal = $("[data-ge-basket-subtotals]"),
                total = $("[data-ge-basket-totals]");

            assertDom(subtotal, "Expected to find order subtotal");
            assertDom(total, "Expected to find order total");

            _.forEach(orderDiscounts(discounts), verifyOrderDiscount);
        },

        verifyOrderDiscount = function(discount) {
            var element = $("[data-ge-basket-discounts='" + discount.DiscountCode + "']");

            assertDom(element, "Expected to find order discount " + discount.Name + " : " + discount.DiscountCode);
            assertPrice(element, discount.OriginalDiscountValue);
        },

        orderDiscounts = function(discounts) {
            return _.filter(discounts, function(discount) { return _.isUndefined(discount.ProductCartItemId); });
        },

        assertDom = function(element, errorMessage) {
            if (_.isEmpty(element)) {
                throw errorMessage;
            }
        },

        refuteDom = function(element, errorMessage) {
            try {
                assertDom(element, errorMessage);
                throw errorMessage;
            }
            catch(error) { return true; }
        },

        assertPrice = function(element, expected) {
            var actual = parseFloat(element.text().replace(/-?\$/, ""));
            if (actual !== expected) {
                throw "Expected " + actual + " to equal " + expected;
            }
        },

        init = function() {
            if (WORKAREA.url.parse(WORKAREA.url.current()).path !== "/cart") {
                return;
            }

            checkoutInfo().done(function(cart) {
                _.forEach(cart.productsList, function(product) {
                    verifyProductPrices(product, cart.discountsList);
                });

                if (!_.isEmpty(cart.productsList)) {
                    verifyOrderPrices(cart.productsList, cart.discountsList);
                }
            });
        };

    return {
        init: init
    };
}()));
