/**
 * @providesModule AssetDelivery
 */

var { NativeModules } = require("react-native");
var RNAssetDelivery = NativeModules.RNAssetDelivery || {};

var AssetDelivery = {
    getPackLocation(name) {
        return RNAssetDelivery.getPackLocation(name);
    },
    getPackContent(name) {
        return RNAssetDelivery.getPackContent(name);
    },
    getPackState(name) {
        return RNAssetDelivery.getPackState(name);
    },
    fetchPack(name) {
        return RNAssetDelivery.fetchPack(name);
    },
    removePack(name) {
        return RNAssetDelivery.removePack(name);
    }
};

module.exports = AssetDelivery;
