#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MediaPicker, NSObject)

RCT_EXTERN_METHOD(launchGallery:(NSDictionary *)params
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(exportVideoFromId:(NSDictionary *)params
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
