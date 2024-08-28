
#import <Foundation/Foundation.h>

typedef void(^JHNetworkSpeedBlock)(NSString *uploadSpeed,NSString *downloadSpeed, NSString *totalDownload, NSString *totalUpload);

@interface JHNetworkSpeed : NSObject

@property (nonatomic, copy) JHNetworkSpeedBlock speedBlock;

+ (instancetype)share;

- (void)start;
- (void)stop;

@end
