import { NativeModules, Platform } from 'react-native';
const LINKING_ERROR = `The package 'react-native-nia-bridge' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const NiaBridge = NativeModules.NiaBridge ? NativeModules.NiaBridge : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
export function register(niaAccessToken, destination) {
  return NiaBridge.register(niaAccessToken, destination);
}
export function login(destination) {
  return NiaBridge.login(destination);
}
export function isLoggedIn() {
  return NiaBridge.isLoggedIn();
}
export function logoutAndClear() {
  return NiaBridge.logoutAndClear();
}
export function isDeviceRegistered() {
  return NiaBridge.isDeviceRegistered();
}
export function getToken() {
  return NiaBridge.getToken().then(token => {
    if (typeof token === 'string' && token.length > 0) return token;
    return null;
  });
}
export default NiaBridge;
//# sourceMappingURL=index.js.map