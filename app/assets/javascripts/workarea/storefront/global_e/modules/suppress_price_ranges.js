/**
 * @namespace WORKAREA.global_e
 */

WORKAREA.registerModule('global_e_price_filter', (function () {
    var  isOperatedByGlobalE = function() {
            return WORKAREA.cookie.read('GlobalE_IsOperated') === "true";
        },

        init = function($scope) {
            if (!isOperatedByGlobalE()) { return; }

            $('.result-filters__section--price', $scope).hide();
        };

    return {
        init: init
    };
}()));
