
#import "JHNetworkSpeed.h"
#include <net/if.h>
#include <ifaddrs.h>

@interface JHNetworkSpeed()

@property (nonatomic,    copy) NSString *uploadSpeed;
@property (nonatomic,    copy) NSString *downloadSpeed;

@property (nonatomic,    copy) NSString *totalUploadSpeed;
@property (nonatomic,    copy) NSString *totalDownloadSpeed;

@property (nonatomic,  strong) NSTimer *timer;

@property (nonatomic,  assign) uint32_t  inBytes;
@property (nonatomic,  assign) uint32_t  outBytes;

@end

@implementation JHNetworkSpeed
static uint32_t  totalDownload;
static uint32_t  totalUpload;

+ (instancetype)share{
    static JHNetworkSpeed *speed;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        speed = [[JHNetworkSpeed alloc] init];
    });
    return speed;
}

- (void)fetchInterfaceBytes{
    struct ifaddrs *ifaddrs_list = 0;
    if (getifaddrs(&ifaddrs_list) == -1) {
        _uploadSpeed = @"0B";
        _downloadSpeed = @"0B";
        return;
    }
    
    uint32_t inBytes = 0;
    uint32_t outBytes = 0;
    struct ifaddrs *ifaddrs;
    for (ifaddrs = ifaddrs_list; ifaddrs; ifaddrs = ifaddrs->ifa_next) {
        if (AF_LINK != ifaddrs->ifa_addr->sa_family) {
            continue;
        }
        
        if (!(IFF_UP & ifaddrs->ifa_flags) &&
            !(IFF_RUNNING & ifaddrs->ifa_flags)) {
            continue;
        }
        
        if (ifaddrs->ifa_data == 0) {
            continue;
        }
        if (strncmp(ifaddrs->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifaddrs->ifa_data;
            inBytes += if_data->ifi_ibytes;
            outBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifaddrs_list);
    
    if (_inBytes != 0) {
        _downloadSpeed = [self bytesToString:inBytes-_inBytes];
        
        totalDownload = totalDownload + (inBytes-_inBytes);
        _totalDownloadSpeed = [self bytesToString:totalDownload];
    }
    _inBytes = inBytes;

    if (_outBytes != 0) {
         _uploadSpeed = [self bytesToString:outBytes-_outBytes];
        
        totalUpload = totalUpload + (outBytes-_outBytes);
        _totalUploadSpeed = [self bytesToString:totalUpload];
    }
    _outBytes = outBytes;
    
    if (_speedBlock) {
        _speedBlock(_uploadSpeed,_downloadSpeed, _totalDownloadSpeed, _totalUploadSpeed);
    }
}

- (NSString *)bytesToString:(uint32_t)bytes{
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%d Bs", bytes];
    }else if(bytes >= 1024 && bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f Kbs", (double)bytes / 1024];
    }else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f Mbs", (double)bytes / (1024 * 1024)];
    }else{
        return [NSString stringWithFormat:@"%.3f Gbs", (double)bytes / (1024 * 1024 * 1024)];
    }
}

- (NSTimer *)timer{
    if (!_timer) {
        totalDownload = 0;
        totalUpload = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fetchInterfaceBytes) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)start{
    [self stop];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [_timer invalidate];
    _timer = nil;
}

@end
