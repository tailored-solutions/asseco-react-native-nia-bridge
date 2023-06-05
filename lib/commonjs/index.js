"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
exports.getToken = getToken;
exports.isDeviceRegistered = isDeviceRegistered;
exports.isLoggedIn = isLoggedIn;
exports.login = login;
exports.logoutAndClear = logoutAndClear;
exports.register = register;
var _reactNative = require("react-native");
const LINKING_ERROR = `The package 'react-native-nia-bridge' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const NiaBridge = _reactNative.NativeModules.NiaBridge ? _reactNative.NativeModules.NiaBridge : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
function register(niaAccessToken, destination) {
  return NiaBridge.register(niaAccessToken, destination);
}
function login(destination) {
  return NiaBridge.login(destination);
}
function isLoggedIn() {
  return NiaBridge.isLoggedIn();
}
function logoutAndClear() {
  return NiaBridge.logoutAndClear();
}
function isDeviceRegistered() {
  return NiaBridge.isDeviceRegistered();
}
function getToken() {
  return NiaBridge.getToken().then(token => {
    if (typeof token === 'string' && token.length > 0) return token;
    return null;
  });
}
var _default = NiaBridge;
exports.default = _default;
//# sourceMappingURL=index.js.map