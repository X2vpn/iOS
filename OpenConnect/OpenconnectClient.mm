//
//  OpenconnectClient.m
//  OpenConnectNew
//
//  Created by Tran Viet Anh on 4/10/18.
//  Copyright © 2018 NextVPN Corporation. All rights reserved.
//

#import "OpenconnectClient.h"

#import <NetworkExtension/NetworkExtension.h>

@implementation OpenconnectClient

#pragma mark - Lazy Initialization
- (instancetype)init {
    if (self = [super init]) {
        //_vpnAdapter = new OpenConnectAdapter(self);
    }
    return self;
}
- (OpenVPNNetworkSettingsBuilder *)networkSettingsBuilder {
    if (!_networkSettingsBuilder) {
        _networkSettingsBuilder = [[OpenVPNNetworkSettingsBuilder alloc] init];
    }
    return _networkSettingsBuilder;
}
// C "trampoline" function to invoke Objective-C method
int MyObjectDoSomethingWith (struct oc_ip_info *info_ip)
{
    
    // set network setting to Network builder
    OpenconnectClient *client = [[OpenconnectClient alloc] init];
    OpenVPNNetworkSettingsBuilder *buider = [client networkSettingsBuilder];
    // set server
    [buider setRemoteAddress:@"173.244.217.121"];
    
    // setip
    [buider.ipv4LocalAddresses addObject:@"ip address"];
    [buider.ipv4SubnetMasks addObject:@"subnet"];
    buider.ipv4DefaultGateway = @"gateway";
    
    //dns
    [buider.dnsServers addObject:@"8.8.8.8"];
    [buider.dnsServers addObject:@"8.8.4.8"];
    
    // add route
    NSString *subnetMask = @"subnet";
    NEIPv4Route *route = [[NEIPv4Route alloc] initWithDestinationAddress:@"routeAddress" subnetMask:subnetMask];
    
    [buider.ipv4IncludedRoutes addObject:route];
    [buider.ipv4ExcludedRoutes addObject:route];
    
    
    [client establishTunnel];
    
    // Call the Objective-C method using Objective-C syntax
    NSLog(@"IN HeSSD");
    
    
    return 1234;
}

- (BOOL)addIPV4Address:(NSString *)address subnetMask:(NSString *)subnetMask gateway:(NSString *)gateway {
    self.networkSettingsBuilder.ipv4DefaultGateway = gateway;
    [self.networkSettingsBuilder.ipv4LocalAddresses addObject:address];
    [self.networkSettingsBuilder.ipv4SubnetMasks addObject:subnetMask];
    
    return YES;
}

- (BOOL)establishTunnel{
    NEPacketTunnelNetworkSettings *networkSettings = [self.networkSettingsBuilder networkSettings];
    if (!networkSettings) { return NO; }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    void (^completionHandler)(id<OpenVPNAdapterPacketFlow> _Nullable) = ^(id<OpenVPNAdapterPacketFlow> flow) {
        __strong typeof(self) self = weakSelf;
        
        if (flow) {
            self.packetFlowBridge = [[OpenVPNPacketFlowBridge alloc] initWithPacketFlow:flow];
        }
        
        dispatch_semaphore_signal(semaphore);
    };
    
    // send to NE
   [self.delegate openVPNAdapter:networkSettings completionHandler:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    
    NSError *socketError;
    if (self.packetFlowBridge && [self.packetFlowBridge configureSocketsWithError:&socketError]) {
        [self.packetFlowBridge startReading];
        return YES;
    } else {
        if (socketError) {
           [self.delegate openVPNAdapter:socketError];
            
        }
        return NO;
    }
}

- (void) startWithOptions:(NSArray*)options{
    [_vpnAdapter startWithOptions:@[@"--user", @"test33",
                                           @"104.222.32.68"]];
}

- (int) doSomethingWith
{
    // The Objective-C function you wanted to call from C++.
    // do work here..
    return 21 ; // half of 42
}

@end
