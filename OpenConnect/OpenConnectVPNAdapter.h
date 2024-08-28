//
//  OpenVPNAdapter.h
//  OpenConnectNew
//
//  Created by CYTECH on 4/10/18.
//  Copyright © 2018 NextVPN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenconnectClient.h"
@protocol OpenVPNAdapterDelegate <NSObject>
/**
 This method is called once the network settings to be used have been established.
 The receiver should call the completion handler once these settings have been set, returning a NEPacketTunnelFlow object for
 the TUN interface, or nil if an error occurred.
 
 @param networkSettings The NEPacketTunnelNetworkSettings to be used for the tunnel.
 @param completionHandler The completion handler to be called with a NEPacketTunnelFlow object, or nil if an error occurred.
 */
- (void)openVPNAdapter:(NEPacketTunnelNetworkSettings *_Nullable)networkSettings
     completionHandler:(void (^_Nullable)(id<OpenVPNAdapterPacketFlow> _Nullable packetFlow))completionHandler;

/**
 Informs the receiver that an OpenVPN error has occurred.
 Some errors are fatal and should trigger the diconnection of the tunnel, check for fatal errors with the
 OpenVPNAdapterErrorFatalKey.
 @param error The error which has occurred.
 */
- (void)openVPNAdapter:(NSError *_Nullable)error;

@end
