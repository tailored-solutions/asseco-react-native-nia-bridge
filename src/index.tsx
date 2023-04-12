import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-nia-bridge' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const NiaBridge = NativeModules.NiaBridge
  ? NativeModules.NiaBridge
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function register(
  niaAccessToken: string,
  destination: string
): Promise<boolean> {
  return NiaBridge.register(niaAccessToken, destination);
}

export function login(destination: string): Promise<boolean> {
  return NiaBridge.login(destination);
}

export function isLoggedIn(): Promise<boolean> {
  return NiaBridge.isLoggedIn();
}

export function logoutAndClear(): Promise<boolean> {
  return NiaBridge.logoutAndClear();
}

export function isDeviceRegistered(): Promise<boolean> {
  return NiaBridge.isDeviceRegistered();
}

export function getToken(): Promise<string | null> {
  return NiaBridge.getToken().then((token: string | null) => {
    if (typeof token === 'string' && token.length > 0) return token;

    return null;
  });
}

export default NiaBridge;
