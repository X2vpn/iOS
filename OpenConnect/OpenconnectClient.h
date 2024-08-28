//
//  OpenconnectClient.h
//  OpenConnectNew
//
//  Created by Tran Viet Anh on 4/10/18.
//  Copyright © 2018 NextVPN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>   
#include "cplus_objectivec.h"
#import "OpenVPNAdapterPacketFlow.h"
#import "OpenVPNPacketFlowBridge.h"
#import "OpenVPNNetworkSettingsBuilder.h"
#import "OpenConnectVPNAdapter.h"
#import "openconnect.h"
#import "OpenConnectAdapter.h"
@interface OpenconnectClient : NSObject{
    
}
@property (nonatomic) OpenConnectAdapter *vpnAdapter;
@property (nonatomic, weak) id<OpenVPNAdapterDelegate> delegate;
@property (nonatomic) OpenVPNPacketFlowBridge *packetFlowBridge;
@property (nonatomic) OpenVPNNetworkSettingsBuilder *networkSettingsBuilder;
- (BOOL)establishTunnel;
- (void) startWithOptions:(NSArray*)options;
- (int) doSomethingWith;
@end

