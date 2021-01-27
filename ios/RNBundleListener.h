#import <Foundation/Foundation.h>
#import "RNAssetDelivery.h"

@interface RNBundleListener : NSObject
- (id)initWithName:(NSString *)name fromParent:(RNAssetDelivery *)parent;
- (void)accessResource;
- (void)removeObserver;
- (void)endAccess;
@end
