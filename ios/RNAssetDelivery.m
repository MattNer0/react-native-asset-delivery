#import "RNAssetDelivery.h"
#import "RNBundleListener.h"
#import <React/RCTLog.h>

@interface RNAssetDelivery ()
  @property (nonatomic) NSMutableDictionary<NSString*, NSBundleResourceRequest*> *resourceRequest;
  @property (nonatomic) NSString *fetchTag;
  @property (nonatomic) NSMutableArray *fetchingTags;
  @property bool hasListeners;
  //@property RCTResponseSenderBlock progressCallback;
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
    NSLog(@"Invalidate RNAssetDelivery");
    for (NSString *name in self.fetchingTags) {
        @try {
            [self.resourceRequest[name].progress removeObserver:self forKeyPath:@"fractionCompleted" context:&name];
        }
        @catch(NSException *exception) {
            NSLog(@"Fdd Exc: %@ ", exception.name);
            NSLog(@"Fdd Reason: %@ ", exception.reason);
        }
    }

    [self.fetchingTags removeAllObjects];
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    self.resourceRequest = [[NSMutableDictionary alloc] init];
    self.fetchingTags = [[NSMutableArray alloc] init];

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

RCT_EXPORT_METHOD(getPacksState:(NSArray *)names 
    resolver:(RCTPromiseResolveBlock)resolve 
    rejecter:(RCTPromiseRejectBlock)reject) {

    @try {
        NSSet *tags = [NSSet setWithArray: names];
        NSString *name = [names componentsJoinedByString:@","];
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
        if (@available(iOS 9.0, *)) {
            //self.fetchTag = name;
            RNBundleListener *mRequest = [[RNBundleListener alloc] initWithName:name fromParent:self];
            [mRequest accessResource];
            resolve(@(YES));
        } else {
            NSLog(@"Invalid iOS version");
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
        } else {
            NSLog(@"Invalid iOS version");
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
