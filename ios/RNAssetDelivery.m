#import "RNAssetDelivery.h"
#import "RNBundleListener.h"
#import <React/RCTLog.h>

@interface RNAssetDelivery ()
  @property (nonatomic) NSMutableDictionary<NSString*, NSBundleResourceRequest*> *checkRequest;
  @property (nonatomic) NSMutableDictionary<NSString*, RNBundleListener*> *downloadRequest;
  @property (nonatomic) NSString *fetchTag;
  @property (nonatomic) NSMutableArray *fetchingTags;
  @property bool hasListeners;
@end

@implementation RNAssetDelivery

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onProgress"];
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    self.hasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    self.hasListeners = NO;
}

- (void)sendEventPercentage:(NSNumber *)perc
                    withBundle:(NSString *)name
{
    if (self.hasListeners) {
        [self sendEventWithName:@"onProgress" body:@{@"percentage": perc, @"name": name }];
    }
}

- (void)invalidate
{
    RCTLogInfo(@"Invalidate RNAssetDelivery");
    for (NSString *name in self.fetchingTags) {
        @try {
            [self.downloadRequest[name] removeObserver];
        }
        @catch(NSException *exception) {
            RCTLogWarn(@"Fdd Exc: %@ ", exception.name);
            RCTLogWarn(@"Fdd Reason: %@ ", exception.reason);
        }
    }

    [self.fetchingTags removeAllObjects];
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    self.checkRequest = [[NSMutableDictionary alloc] init];
    self.downloadRequest = [[NSMutableDictionary alloc] init];
    self.fetchingTags = [[NSMutableArray alloc] init];

    return self;
}

RCT_EXPORT_METHOD(getPackState:(NSString *)name 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        if (@available(iOS 9.0, *)) {
            NSSet *tags = [NSSet setWithArray: @[name]];
            self.checkRequest[name] = [[NSBundleResourceRequest alloc] initWithTags:tags];
            [self.checkRequest[name] conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                            ^(BOOL resourcesAvailable)
                {
                    if (resourcesAvailable) {
                        resolve(@(YES));
                    } else {
                        resolve(@(NO));
                    }
                }
            ];
        } else {
            RCTLogWarn(@"Invalid iOS version");
            resolve(@(NO));
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

RCT_EXPORT_METHOD(getPacksState:(NSArray *)names 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        if (@available(iOS 9.0, *)) {
            NSSet *tags = [NSSet setWithArray: names];
            NSString *name = [names componentsJoinedByString:@","];
            self.checkRequest[name] = [[NSBundleResourceRequest alloc] initWithTags:tags];
            [self.checkRequest[name] conditionallyBeginAccessingResourcesWithCompletionHandler:
                                                            ^(BOOL resourcesAvailable)
                {
                    if (resourcesAvailable) {
                        resolve(@(YES));
                    } else {
                        resolve(@(NO));
                    }
                }
            ];
        } else {
            RCTLogWarn(@"Invalid iOS version");
            resolve(@(NO));
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
        if (@available(iOS 9.0, *)) {
            //self.fetchTag = name;
            [self.fetchingTags addObject:name];
            self.downloadRequest[name] = [[RNBundleListener alloc] initWithName:name fromParent:self];
            [self.downloadRequest[name] accessResource];
            RCTLogInfo(@"Download start");
            resolve(@(YES));
        } else {
            RCTLogWarn(@"Invalid iOS version");
            resolve(@(NO));
        }
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
        if (@available(iOS 9.0, *)) {
            if ([self.checkRequest objectForKey:name]) {
                [self.checkRequest[name] endAccessingResources];
                resolve(@(YES));
                return;
            }

            if ([self.downloadRequest objectForKey:name]) {
                [self.downloadRequest[name] endAccess];
                resolve(@(YES));
                return;
            }

            /*else {
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
            }*/

            RCTLogWarn(@"No request for bundle");
            resolve(@(NO));
        } else {
            RCTLogWarn(@"Invalid iOS version");
            resolve(@(NO));
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
