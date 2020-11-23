#import "RNAssetDelivery.h"

@implementation RNAssetDelivery

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(getPackState:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        NSBundleResourceRequest resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        [resourceRequest conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                        ^(BOOL resourcesAvailable)
            {
                if (resourcesAvailable) {
                    resolve(YES);
                } else {
                    resolve(NO);
                }
            }
        ];
    }
    @catch(NSException *exception) {
        reject(@"error", @"Couldn't get pack state.", exception);
    }
}

RCT_REMAP_METHOD(getPackLocation:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(YES);
}

RCT_REMAP_METHOD(getPackContent:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        NSBundleResourceRequest resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        [resourceRequest conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                        ^(BOOL resourcesAvailable)
            {
                if (resourcesAvailable) {
                    NSArray *filePaths = [NSBundle pathsForResourcesOfType:nil inDirectory:[[NSBundle resourceRequest.bundle] bundlePath]];
                    resolve(filePaths);
                } else {
                    reject(@"error", @"resources not available", error);
                }
            }
        ];
    }
    @catch(NSException *exception) {
        reject(@"error", @"Couldn't get pack content.", exception);
    }
}

RCT_REMAP_METHOD(fetchPack:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithObjects: name];
        // Use the shorter initialization method as all resources are in the main bundle
        NSBundleResourceRequest resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
        resourceRequest.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent;
        [resourceRequest beginAccessingResourcesWithCompletionHandler:
                                    ^(NSError * __nullable error)
            {
                if (error) {
                    reject(@"error", @"resources not available", error);
                    return;
                }
        
                // The associated resources are loaded
                resolve(YES);
            }
        ];
    }
    @catch(NSException *exception) {
        reject(@"error", @"Couldn't fetch pack.", exception);
    }
}

@end
