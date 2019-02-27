/**
 * @namespace WORKAREA.global_e
 */

WORKAREA.registerModule('global_e_price_filter', (function () {
    var globalECookie = function() {
            try {
                return JSON.parse(decodeURIComponent(WORKAREA.cookie.read('GlobalE_Data'))) || {};
            }
            catch (err) {
                return {};
            }
        },

        shippingCountry = function() {
            return globalECookie().countryISO;
        },

        init = function($scope) {
            if (_.isNull(shippingCountry()) || _.includes(WORKAREA.config.globalE.domesticCountries, shippingCountry())) {
                return;
            }

            $('.result-filters__section--price', $scope).hide();
        };

    return {
        init: init
    };
}()));
