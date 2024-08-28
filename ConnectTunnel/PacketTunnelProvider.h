
@import NetworkExtension;
#import "OpenConnectAdapter.h"
#import "OpenAdapter.h"
#import "OpenVPNAdapter.h"
#import "OpenVPNReachability.h"

@interface PacketTunnelProvider : NEPacketTunnelProvider <OpenAdapterDelegate, OpenVPNAdapterDelegate>

@property(nonatomic,strong) OpenVPNAdapter *openVpnAdapter;
@property(nonatomic,strong) OpenVPNReachability *openVpnReach;

typedef void(^StartHandler)(NSError * _Nullable);
typedef void(^StopHandler)(void);

@property(nonatomic,copy) StartHandler startHandler;
@property(nonatomic,copy) StopHandler stopHandler;

@end
