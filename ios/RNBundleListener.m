#import "RNBundleListener.h"
#import "RNAssetDelivery.h"
#import <React/RCTLog.h>

@interface RNBundleListener ()
  @property (nonatomic) NSString *bundleName;
  @property (nonatomic) NSSet *tags;
  @property (nonatomic) NSBundleResourceRequest *resourceRequest;
  @property (nonatomic) RNAssetDelivery *mParent;
@end

@implementation RNBundleListener

- (id)initWithName:(NSString *)name
                fromParent:(RNAssetDelivery *)parent
{
    self = [super init];
    if (self) {
        self.bundleName = name;
        self.mParent = parent;
        self.tags = [NSSet setWithArray: @[name]];
    }
    return self;
}

- (void)removeObserver
{
    @try {
        [self.resourceRequest.progress removeObserver:self forKeyPath:@"fractionCompleted" context:nil];
    }
    @catch(NSException *exception) {
        RCTLogWarn(@"Fdd Exc: %@ ", exception.name);
        RCTLogWarn(@"Fdd Reason: %@ ", exception.reason);
    }
}

- (void)endAccess
{
    @try {
        [self.resourceRequest endAccessingResources];
    }
    @catch(NSException *exception) {
        RCTLogWarn(@"Fdd Exc: %@ ", exception.name);
        RCTLogWarn(@"Fdd Reason: %@ ", exception.reason);
    }
}

- (void)accessResource
{
    @try {
        if (@available(iOS 9.0, *)) {
            self.resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:self.tags];
            self.resourceRequest.loadingPriority = 0.8; //NSBundleResourceRequestLoadingPriorityUrgent;
            [self.resourceRequest.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
            [self.resourceRequest beginAccessingResourcesWithCompletionHandler:
                                        ^(NSError * __nullable error)
                {
                    if (error) {
                        RCTLogInfo(@"Resource error");
                        return;
                    }
            
                    // The associated resources are loaded
                    RCTLogInfo(@"Resource loaded");
                }
            ];
        } else {
            RCTLogWarn(@"Invalid iOS version");
        }
    }
    @catch(NSException *exception) {
        RCTLogWarn(@"Fdd Exc: %@ ", exception.name);
        RCTLogWarn(@"Fdd Reason: %@ ", exception.reason);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                ofObject:(id)object
                change:(NSDictionary *)change
                context:(void *)context
{
    @try {
        if ([keyPath isEqualToString:@"fractionCompleted"]) {
            NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
            [self.mParent sendEventPercentage:newValue withBundle:self.bundleName];
        }
    }
    @catch(NSException *exception) {
        RCTLogWarn(@"Fdd Exc: %@ ", exception.name);
        RCTLogWarn(@"Fdd Reason: %@ ", exception.reason);
    }
}

@end
