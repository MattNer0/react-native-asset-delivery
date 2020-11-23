#import "RNAssetDelivery.h"

@implementation RNAssetDelivery

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(getPackState:(NSString *)name, getPackStateWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

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

RCT_REMAP_METHOD(getPackLocation:(NSString *)name, getPackLocationWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(YES);
}

RCT_REMAP_METHOD(getPackContent:(NSString *)name, getPackContentWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

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

RCT_REMAP_METHOD(fetchPack:(NSString *)name, fetchPackWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

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

@end
