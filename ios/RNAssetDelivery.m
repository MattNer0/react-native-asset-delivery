#import "RNAssetDelivery.h"
#import <React/RCTLog.h>

@interface RNAssetDelivery ()
  @property (nonatomic) NSMutableDictionary<NSString*, NSBundleResourceRequest*> *resourceRequest;
@end

@implementation RNAssetDelivery

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    self.resourceRequest = [[NSMutableDictionary alloc] init];

    return self;
}

RCT_EXPORT_METHOD(getPackState:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithArray: @[name]];
        self.resourceRequest[name] = [[NSBundleResourceRequest alloc] initWithTags:tags];
        [self.resourceRequest[name] conditionallyBeginAccessingResourcesWithCompletionHandler:
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
        NSError *err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
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
    RCTLogWarn(@"Method 'getPackLocation' not valid");
    resolve(@(NO));
}

RCT_EXPORT_METHOD(getPackContent:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {
    RCTLogWarn(@"Method 'getPackContent' not valid");
    resolve(@(NO));
}

RCT_EXPORT_METHOD(getPackFileUrl:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
        NSString *urlString = [fileUrl absoluteString];
        resolve(urlString);
    }
    @catch(NSException *exception) {
        NSError *err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
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
        NSSet *tags = [NSSet setWithArray: @[name]];
        self.resourceRequest[name] = [[NSBundleResourceRequest alloc] initWithTags:tags];
        self.resourceRequest[name].loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent;
        [self.resourceRequest[name] beginAccessingResourcesWithCompletionHandler:
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
        NSError *err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSUnderlyingErrorKey: exception,
            NSDebugDescriptionErrorKey: exception.userInfo ?: @{ },
            NSLocalizedFailureReasonErrorKey: (exception.reason ?: @"???")
        }];
        reject(@"error", @"Couldn't fetch pack.", err);
    }
}

RCT_EXPORT_METHOD(removePack:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        if ([self.resourceRequest objectForKey:name]) {
            [self.resourceRequest[name] endAccessingResources];
            resolve(@(YES));
        } else {
            __weak typeof(self.resourceRequest) weakDictionary = self.resourceRequest;
            NSSet *tags = [NSSet setWithArray: @[name]];
            self.resourceRequest[name] = [[NSBundleResourceRequest alloc] initWithTags:tags];
            [self.resourceRequest[name] conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                            ^(BOOL resourcesAvailable)
                {
                    __strong typeof(weakDictionary) strongDictionary = weakDictionary;
                    if (resourcesAvailable) {
                        [strongDictionary[name] endAccessingResources];
                    }

                    resolve(@(YES));
                }
            ];
        }
    }
    @catch(NSException *exception) {
        NSError *err = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSUnderlyingErrorKey: exception,
            NSDebugDescriptionErrorKey: exception.userInfo ?: @{ },
            NSLocalizedFailureReasonErrorKey: (exception.reason ?: @"???")
        }];
        reject(@"error", @"Couldn't get pack state.", err);
    }
}

@end
