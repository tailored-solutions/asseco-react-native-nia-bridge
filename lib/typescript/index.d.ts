declare const NiaBridge: any;
export declare function register(niaAccessToken: string, destination: string): Promise<boolean>;
export declare function login(destination: string): Promise<boolean>;
export declare function isLoggedIn(): Promise<boolean>;
export declare function logoutAndClear(): Promise<boolean>;
export declare function isDeviceRegistered(): Promise<boolean>;
export declare function getToken(): Promise<string | null>;
export default NiaBridge;
//# sourceMappingURL=index.d.ts.map