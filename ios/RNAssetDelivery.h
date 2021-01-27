#import <Foundation/Foundation.h>

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#endif

@interface RNAssetDelivery : RCTEventEmitter <RCTBridgeModule>
- (void)sendEventPercentage:(NSNumber *)perc withBundle:(NSString *)name;
@end
