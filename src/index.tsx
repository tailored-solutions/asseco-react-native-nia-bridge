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
