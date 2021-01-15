/**
 * @providesModule RNAssetDelivery
 */

var { NativeModules, NativeEventEmitter } = require("react-native");
var RNAssetDelivery = NativeModules.RNAssetDelivery || {};
var eventEmitter

try {
    eventEmitter = new NativeEventEmitter(RNAssetDelivery);
} catch(err) {
    console.warn(err.message)
}

let hasListener = false

var AssetDelivery = {
    getPackLocation(name) {
        return RNAssetDelivery.getPackLocation(name);
    },
    getPackContent(name) {
        return RNAssetDelivery.getPackContent(name);
    },
    getPackFileUrl(name) {
        return RNAssetDelivery.getPackFileUrl(name);
    },
    getPackState(name) {
        return RNAssetDelivery.getPackState(name);
    },
    getPacksState(names) {
        return RNAssetDelivery.getPacksState(names);
    },
    fetchPack(name) {
        return RNAssetDelivery.fetchPack(name);
    },
    removePack(name) {
        return RNAssetDelivery.removePack(name);
    },
    addProgressListener(callback) {
        hasListener = true
        return eventEmitter.addListener('onProgress', callback);
    },
    hasProgressListener() {
        return Boolean(hasListener)
    },
    checkUpdate() {
        return RNAssetDelivery.checkUpdate();
    },
    removeAllListeners() {
        hasListener = false
        try {
            eventEmitter.removeAllListeners('onProgress')
        } catch (err) {
            console.warn(err.message)
        }
    }
};

module.exports = AssetDelivery;
