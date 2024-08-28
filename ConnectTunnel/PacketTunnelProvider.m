
#import "PacketTunnelProvider.h"
#import "OpenVPNConfiguration.h"
#import "OpenVPNProperties.h"
#import "OpenVPNCredentials.h"
#import "OpenVPNReachabilityStatus.h"
#import "OpenVPNError.h"
#import "OpenVPNAdapterEvent.h"

@implementation PacketTunnelProvider{
    OpenAdapter *vpnAdapter;
    NWTCPConnection *_TCPConnection;
    NSDictionary *config;
    NSString *host;
    NSString *username;
    NSString *password;
    NSString *option;
}

-(OpenVPNAdapter*)openVpnAdapter{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rivernet.x2vpnios"];
    NSString *vpnCategory = [userDefaults objectForKey:@"VPNCategory"];
    
    if ([vpnCategory isEqualToString:@"OpenVPN"]) {

        if(!_openVpnAdapter){
            _openVpnAdapter = [[OpenVPNAdapter alloc] init];
            _openVpnAdapter.delegate = self;
        }
        return _openVpnAdapter;
    } else{
        return nil;
    }
}

-(OpenVPNReachability*)openVpnReach{
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rivernet.x2vpnios"];
    NSString *vpnCategory = [userDefaults objectForKey:@"VPNCategory"];
    
    if ([vpnCategory isEqualToString:@"OpenVPN"]) {
        if(!_openVpnReach){
            _openVpnReach = [[OpenVPNReachability alloc] init];
        }
        return _openVpnReach;
        
    } else{
        return nil;
    }
}


- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rivernet.x2vpnios"];
    NSString *vpnCategory = [userDefaults objectForKey:@"VPNCategory"];
    
    NSLog(@"start tunnel");
    
    if ([vpnCategory isEqualToString:@"OpenVPN"]) {
        
        NETunnelProviderProtocol *proto =  (NETunnelProviderProtocol*)self.protocolConfiguration;
        if(!proto){
            NSLog(@"Proto Error =>");
            return;
        }
        NSDictionary<NSString *,id> *provider = proto.providerConfiguration;
        NSData * fileContent = provider[@"ovpn"];
        OpenVPNConfiguration *openVpnConfiguration = [[OpenVPNConfiguration alloc] init];
        openVpnConfiguration.fileContent = fileContent;
        NSError *error;
        OpenVPNProperties *properties = [self.openVpnAdapter applyConfiguration:openVpnConfiguration error:&error];
        if(error){
            NSLog(@"Configuration Error => %@", error.localizedDescription);
            return;
        }
        
        if(!properties.autologin){
            OpenVPNCredentials *credentials = [[OpenVPNCredentials alloc] init];
            credentials.username = [NSString stringWithFormat:@"%@",[options objectForKey:@"username"]];
            credentials.password = [NSString stringWithFormat:@"%@",[options objectForKey:@"password"]];
            [self.openVpnAdapter provideCredentials:credentials error:&error];
            if(error){
                NSLog(@"Credential Error => %@", error.localizedDescription);
                return;
            }
        }
        
        [self.openVpnReach startTrackingWithCallback:^(OpenVPNReachabilityStatus status) {
            if(status==OpenVPNReachabilityStatusNotReachable){
                [self.openVpnAdapter reconnectAfterTimeInterval:5];
            }
        }];
        
        [self.openVpnAdapter connect];
        self.startHandler = completionHandler;
    }else {
        NSLog(@"===>");
        vpnAdapter = [[OpenAdapter alloc] init];
        vpnAdapter.delegate = self;
        // get config
        config = [[NSDictionary alloc] init];
        NETunnelProviderProtocol *protocol = (NETunnelProviderProtocol *)self.protocolConfiguration;
        config = protocol.providerConfiguration;
        
        host = config[@"server"];
        
        // Load config data
        username = config[@"username"];
        password = config[@"password"];
        
        option = config[@"option"];
        
        if(option != nil){
            [vpnAdapter connect:host user:username pass:password add:YES];
        }else{
            [vpnAdapter connect:host user:username pass:password add:NO];
        }
        return;
    }
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    // Add code here to start the process of stopping the tunnel.
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rivernet.x2vpnios"];
    NSString *vpnCategory = [userDefaults objectForKey:@"VPNCategory"];
    if ([vpnCategory isEqualToString:@"OpenVPN"]) {
        if ([self.openVpnReach isTracking]) {
            [self.openVpnReach stopTracking];
        }
        
        [self.openVpnAdapter disconnect];
        self.stopHandler = completionHandler;
        completionHandler();
    }else{
        completionHandler();
    }
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
    // Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    // Add code here to get ready to sleep.
    completionHandler();
}

- (void)wake {
    // Add code here to wake up.
}

- (void)openVPNAdapter:(NSError *)error {
    
}

- (void) setupUDPSession: (NEPacketTunnelNetworkSettings *) setting{
    self.reasserting = false;
    NSString *_serverAddress = host;
    NSString *_port = @"443";
    if(_TCPConnection != nil){
        self.reasserting = true;
        _TCPConnection = nil;
    }
    
    [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error){
        if(error != nil){
            NSLog(@"Error set TunnelNetwork %@", error);
        }
        // = [self createUDPSessionToEndpoint:[NWHostEndpoint endpointWithHostname:_serverAddress port:_port] fromEndpoint:nil];
        _TCPConnection = [self createTCPConnectionToEndpoint:[NWHostEndpoint endpointWithHostname:_serverAddress port:_port] enableTLS:false TLSParameters:nil delegate:self];
        [self setTunnelNetworkSettings:setting completionHandler:^(NSError * _Nullable error){
            if(error != nil){
                NSLog(@"%@", error);
            }
        }];
    }];
}

- (void)openConnectVPNAdapter:(OpenAdapter * _Nullable)openVPNAdapter configureTunnelWithNetworkSettings:(NEPacketTunnelNetworkSettings * _Nullable)networkSettings completionHandler:(void (^ _Nullable)(id<OpenAdapterPacketFlow> _Nullable))completionHandler {
    [self setupUDPSession:networkSettings];
    completionHandler(self.packetFlow);
}

- (void)openConnectVPNAdapter:(OpenAdapter * _Nullable)openVPNAdapter handleError:(NSError * _Nullable)error {
    NSLog(@"ERROR IN HERE");
}

#pragma mark OpenVPN Adapter Delegates

-(void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter handleError:(NSError *)error{
    BOOL isOpen = (BOOL)[error userInfo][OpenVPNAdapterErrorFatalKey];
    if(isOpen){
        if (self.openVpnReach.isTracking) {
            [self.openVpnReach stopTracking];
        }
        self.startHandler(error);
        self.startHandler = nil;
    }
}


-(void)openVPNAdapterDidReceiveClockTick:(OpenVPNAdapter *)openVPNAdapter{
    
}

-(void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter handleEvent:(OpenVPNAdapterEvent)event message:(NSString *)message{
    switch (event) {
        case OpenVPNAdapterEventConnected:
            if(self.reasserting){
                self.reasserting = false;
            }
            self.startHandler(nil);
            self.startHandler = nil;
            break;
        case OpenVPNAdapterEventDisconnected:
            if (self.openVpnReach.isTracking) {
                [self.openVpnReach stopTracking];
            }
            self.stopHandler();
            self.stopHandler = nil;
            break;
        case OpenVPNAdapterEventReconnecting:
            self.reasserting = true;
            break;
        default:
            break;
    }
}

-(void)openVPNAdapter:(OpenVPNAdapter *)openVPNAdapter configureTunnelWithNetworkSettings:(NEPacketTunnelNetworkSettings *)networkSettings completionHandler:(void (^)(id<OpenVPNAdapterPacketFlow> _Nullable))completionHandler{
    __weak __typeof(self) weak_self = self;
    [self setTunnelNetworkSettings:networkSettings completionHandler:^(NSError * _Nullable error) {
        if(!error){
            completionHandler(weak_self.packetFlow);
        }
    }];
}


@end
