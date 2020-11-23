#import "RNAssetDelivery.h"

@interface RNAssetDelivery ()
  @property (nonatomic) NSBundleResourceRequest *resourceRequest;
@end

@implementation RNAssetDelivery

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getPackState:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        self.resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        [self.resourceRequest conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                        ^(BOOL resourcesAvailable)
            {
                if (resourcesAvailable) {
                    resolve(@(YES));
                } else {
                    resolve(@(NO));
                }
            }
        ];
    }
    @catch(NSException *exception) {
        NSError err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSUnderlyingErrorKey: exception,
            NSDebugDescriptionErrorKey: exception.userInfo ?: @{ },
            NSLocalizedFailureReasonErrorKey: (exception.reason ?: @"???")
        }];
        reject(@"error", @"Couldn't get pack state.", err);
    }
}

RCT_EXPORT_METHOD(getPackLocation:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(YES);
}

RCT_EXPORT_METHOD(getPackContent:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        __weak typeof(self) weakSelf = self;
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        self.resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        [self.resourceRequest conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                        ^(BOOL resourcesAvailable)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (resourcesAvailable) {
                    NSBundle *resourceBundle = strongSelf.resourceRequest.bundle;
                    NSArray *filePaths = [NSBundle pathsForResourcesOfType:nil inDirectory:[resourceBundle resourcePath]];
                    resolve(filePaths);
                } else {
                    NSError *errMsg = [NSError errorWithDomain:@"getPackContent" code:0 userInfo:nil];
                    reject(@"error", @"resources not available", errMsg);
                }
            }
        ];
    }
    @catch(NSException *exception) {
        NSError err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSUnderlyingErrorKey: exception,
            NSDebugDescriptionErrorKey: exception.userInfo ?: @{ },
            NSLocalizedFailureReasonErrorKey: (exception.reason ?: @"???")
        }];
        reject(@"error", @"Couldn't get pack content.", err);
    }
}

RCT_EXPORT_METHOD(fetchPack:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        self.resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        self.resourceRequest.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent;
        [self.resourceRequest beginAccessingResourcesWithCompletionHandler:
                                    ^(NSError * __nullable error)
            {
                if (error) {
                    reject(@"error", @"resources not available", error);
                    return;
                }
        
                // The associated resources are loaded
                resolve(@(YES));
            }
        ];
    }
    @catch(NSException *exception) {
        reject(@"error", @"Couldn't fetch pack.", exception);
    }
}

@end
