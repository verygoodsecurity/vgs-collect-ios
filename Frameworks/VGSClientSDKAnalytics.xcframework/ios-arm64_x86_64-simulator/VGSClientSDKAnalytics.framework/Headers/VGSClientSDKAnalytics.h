#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class VGSCSDKAVGSAnalyticsEvent, VGSCSDKADefaultEventParams, VGSCSDKAKotlinEnumCompanion, VGSCSDKAKotlinEnum<E>, VGSCSDKAVGSAnalyticsCopyFormat, VGSCSDKAKotlinArray<T>, VGSCSDKAVGSAnalyticsStatus, VGSCSDKAVGSAnalyticsEventAttachFile, VGSCSDKAVGSAnalyticsEventAutofill, VGSCSDKAVGSAnalyticsEventCname, VGSCSDKAVGSAnalyticsEventContentRendering, VGSCSDKAVGSAnalyticsEventContentSharing, VGSCSDKAVGSAnalyticsEventCopyToClipboard, VGSCSDKAVGSAnalyticsEventFieldAttach, VGSCSDKAVGSAnalyticsEventFieldDetach, VGSCSDKAVGSAnalyticsUpstream, VGSCSDKAVGSAnalyticsEventRequest, VGSCSDKAVGSAnalyticsEventRequestBuilder, VGSCSDKAVGSAnalyticsMappingPolicy, VGSCSDKAVGSAnalyticsEventResponse, VGSCSDKAVGSAnalyticsScannerType, VGSCSDKAVGSAnalyticsEventScan, VGSCSDKAVGSAnalyticsEventSecureTextRange, VGSCSDKAVGSAnalyticsUpstreamCompanion, VGSCSDKAVGSAnalyticsSession;

@protocol VGSCSDKAKotlinComparable, VGSCSDKAKotlinIterator;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface VGSCSDKABase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface VGSCSDKABase (VGSCSDKABaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface VGSCSDKAMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface VGSCSDKAMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorVGSCSDKAKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface VGSCSDKANumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface VGSCSDKAByte : VGSCSDKANumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface VGSCSDKAUByte : VGSCSDKANumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface VGSCSDKAShort : VGSCSDKANumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface VGSCSDKAUShort : VGSCSDKANumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface VGSCSDKAInt : VGSCSDKANumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface VGSCSDKAUInt : VGSCSDKANumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface VGSCSDKALong : VGSCSDKANumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface VGSCSDKAULong : VGSCSDKANumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface VGSCSDKAFloat : VGSCSDKANumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface VGSCSDKADouble : VGSCSDKANumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface VGSCSDKABoolean : VGSCSDKANumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSSharedAnalyticsManager")))
@interface VGSCSDKAVGSSharedAnalyticsManager : VGSCSDKABase
- (instancetype)initWithSource:(NSString *)source sourceVersion:(NSString *)sourceVersion dependencyManager:(NSString *)dependencyManager __attribute__((swift_name("init(source:sourceVersion:dependencyManager:)"))) __attribute__((objc_designated_initializer));
- (void)cancelAll __attribute__((swift_name("cancelAll()")));
- (void)captureVault:(NSString *)vault environment:(NSString *)environment formId:(NSString *)formId event:(VGSCSDKAVGSAnalyticsEvent *)event __attribute__((swift_name("capture(vault:environment:formId:event:)")));
- (BOOL)getIsEnabled __attribute__((swift_name("getIsEnabled()")));
- (void)setIsEnabledIsEnabled:(BOOL)isEnabled __attribute__((swift_name("setIsEnabled(isEnabled:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DefaultEventParams")))
@interface VGSCSDKADefaultEventParams : VGSCSDKABase
- (instancetype)initWithVault:(NSString *)vault environment:(NSString *)environment source:(NSString *)source sourceVersion:(NSString *)sourceVersion dependencyManager:(NSString *)dependencyManager __attribute__((swift_name("init(vault:environment:source:sourceVersion:dependencyManager:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKADefaultEventParams *)doCopyVault:(NSString *)vault environment:(NSString *)environment source:(NSString *)source sourceVersion:(NSString *)sourceVersion dependencyManager:(NSString *)dependencyManager __attribute__((swift_name("doCopy(vault:environment:source:sourceVersion:dependencyManager:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSDictionary<NSString *, id> *)getParams __attribute__((swift_name("getParams()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinComparable")))
@protocol VGSCSDKAKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface VGSCSDKAKotlinEnum<E> : VGSCSDKABase <VGSCSDKAKotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) VGSCSDKAKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsCopyFormat")))
@interface VGSCSDKAVGSAnalyticsCopyFormat : VGSCSDKAKotlinEnum<VGSCSDKAVGSAnalyticsCopyFormat *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) VGSCSDKAVGSAnalyticsCopyFormat *raw __attribute__((swift_name("raw")));
@property (class, readonly) VGSCSDKAVGSAnalyticsCopyFormat *formatted __attribute__((swift_name("formatted")));
+ (VGSCSDKAKotlinArray<VGSCSDKAVGSAnalyticsCopyFormat *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<VGSCSDKAVGSAnalyticsCopyFormat *> *entries __attribute__((swift_name("entries")));
- (NSString *)getAnalyticsName __attribute__((swift_name("getAnalyticsName()")));
@end

__attribute__((swift_name("VGSAnalyticsEvent")))
@interface VGSCSDKAVGSAnalyticsEvent : VGSCSDKABase

/**
 * @note annotations
 *   kotlin.jvm.JvmName(name="getEventParams")
*/
- (NSDictionary<NSString *, id> *)getParams __attribute__((swift_name("getParams()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.AttachFile")))
@interface VGSCSDKAVGSAnalyticsEventAttachFile : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status __attribute__((swift_name("init(status:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventAttachFile *)doCopyStatus:(VGSCSDKAVGSAnalyticsStatus *)status __attribute__((swift_name("doCopy(status:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.Autofill")))
@interface VGSCSDKAVGSAnalyticsEventAutofill : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithFieldType:(NSString *)fieldType __attribute__((swift_name("init(fieldType:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventAutofill *)doCopyFieldType:(NSString *)fieldType __attribute__((swift_name("doCopy(fieldType:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.Cname")))
@interface VGSCSDKAVGSAnalyticsEventCname : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status hostname:(NSString *)hostname latency:(VGSCSDKALong * _Nullable)latency __attribute__((swift_name("init(status:hostname:latency:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventCname *)doCopyStatus:(VGSCSDKAVGSAnalyticsStatus *)status hostname:(NSString *)hostname latency:(VGSCSDKALong * _Nullable)latency __attribute__((swift_name("doCopy(status:hostname:latency:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.ContentRendering")))
@interface VGSCSDKAVGSAnalyticsEventContentRendering : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status fieldType:(NSString *)fieldType contentPath:(NSString *)contentPath __attribute__((swift_name("init(status:fieldType:contentPath:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventContentRendering *)doCopyStatus:(VGSCSDKAVGSAnalyticsStatus *)status fieldType:(NSString *)fieldType contentPath:(NSString *)contentPath __attribute__((swift_name("doCopy(status:fieldType:contentPath:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *contentPath __attribute__((swift_name("contentPath")));
@property (readonly) NSString *fieldType __attribute__((swift_name("fieldType")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));
@property (readonly) VGSCSDKAVGSAnalyticsStatus *status __attribute__((swift_name("status")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.ContentSharing")))
@interface VGSCSDKAVGSAnalyticsEventContentSharing : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithContentPath:(NSString *)contentPath __attribute__((swift_name("init(contentPath:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventContentSharing *)doCopyContentPath:(NSString *)contentPath __attribute__((swift_name("doCopy(contentPath:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *contentPath __attribute__((swift_name("contentPath")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.CopyToClipboard")))
@interface VGSCSDKAVGSAnalyticsEventCopyToClipboard : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithFieldType:(NSString *)fieldType contentPath:(NSString *)contentPath format:(VGSCSDKAVGSAnalyticsCopyFormat *)format __attribute__((swift_name("init(fieldType:contentPath:format:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventCopyToClipboard *)doCopyFieldType:(NSString *)fieldType contentPath:(NSString *)contentPath format:(VGSCSDKAVGSAnalyticsCopyFormat *)format __attribute__((swift_name("doCopy(fieldType:contentPath:format:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *contentPath __attribute__((swift_name("contentPath")));
@property (readonly) NSString *fieldType __attribute__((swift_name("fieldType")));
@property (readonly) VGSCSDKAVGSAnalyticsCopyFormat *format __attribute__((swift_name("format")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.FieldAttach")))
@interface VGSCSDKAVGSAnalyticsEventFieldAttach : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithFieldType:(NSString *)fieldType contentPath:(NSString * _Nullable)contentPath ui:(NSString * _Nullable)ui __attribute__((swift_name("init(fieldType:contentPath:ui:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventFieldAttach *)doCopyFieldType:(NSString *)fieldType contentPath:(NSString * _Nullable)contentPath ui:(NSString * _Nullable)ui __attribute__((swift_name("doCopy(fieldType:contentPath:ui:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.FieldDetach")))
@interface VGSCSDKAVGSAnalyticsEventFieldDetach : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithFieldType:(NSString *)fieldType __attribute__((swift_name("init(fieldType:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventFieldDetach *)doCopyFieldType:(NSString *)fieldType __attribute__((swift_name("doCopy(fieldType:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.Request")))
@interface VGSCSDKAVGSAnalyticsEventRequest : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code content:(NSArray<NSString *> *)content __attribute__((swift_name("init(status:code:content:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code content:(NSArray<NSString *> *)content upstream:(VGSCSDKAVGSAnalyticsUpstream *)upstream __attribute__((swift_name("init(status:code:content:upstream:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.RequestBuilder")))
@interface VGSCSDKAVGSAnalyticsEventRequestBuilder : VGSCSDKABase
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code upstream:(VGSCSDKAVGSAnalyticsUpstream *)upstream __attribute__((swift_name("init(status:code:upstream:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventRequest *)build __attribute__((swift_name("build()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)customData __attribute__((swift_name("customData()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)customHeader __attribute__((swift_name("customHeader()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)customHostname __attribute__((swift_name("customHostname()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)fields __attribute__((swift_name("fields()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)files __attribute__((swift_name("files()")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)mappingPolicyPolicy:(VGSCSDKAVGSAnalyticsMappingPolicy *)policy __attribute__((swift_name("mappingPolicy(policy:)")));
- (VGSCSDKAVGSAnalyticsEventRequestBuilder *)pdf __attribute__((swift_name("pdf()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.Response")))
@interface VGSCSDKAVGSAnalyticsEventResponse : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code errorMessage:(NSString * _Nullable)errorMessage __attribute__((swift_name("init(status:code:errorMessage:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code upstream:(VGSCSDKAVGSAnalyticsUpstream *)upstream errorMessage:(NSString * _Nullable)errorMessage __attribute__((swift_name("init(status:code:upstream:errorMessage:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventResponse *)doCopyStatus:(VGSCSDKAVGSAnalyticsStatus *)status code:(int32_t)code upstream:(VGSCSDKAVGSAnalyticsUpstream *)upstream errorMessage:(NSString * _Nullable)errorMessage __attribute__((swift_name("doCopy(status:code:upstream:errorMessage:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.Scan")))
@interface VGSCSDKAVGSAnalyticsEventScan : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status scannerType:(VGSCSDKAVGSAnalyticsScannerType *)scannerType __attribute__((swift_name("init(status:scannerType:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status scannerType:(VGSCSDKAVGSAnalyticsScannerType *)scannerType errorCode:(int32_t)errorCode __attribute__((swift_name("init(status:scannerType:errorCode:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithStatus:(VGSCSDKAVGSAnalyticsStatus *)status scannerType:(VGSCSDKAVGSAnalyticsScannerType *)scannerType scanId:(NSString * _Nullable)scanId scanDetails:(NSString * _Nullable)scanDetails errorCode:(VGSCSDKAInt * _Nullable)errorCode __attribute__((swift_name("init(status:scannerType:scanId:scanDetails:errorCode:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventScan *)doCopyStatus:(VGSCSDKAVGSAnalyticsStatus *)status scannerType:(VGSCSDKAVGSAnalyticsScannerType *)scannerType scanId:(NSString * _Nullable)scanId scanDetails:(NSString * _Nullable)scanDetails errorCode:(VGSCSDKAInt * _Nullable)errorCode __attribute__((swift_name("doCopy(status:scannerType:scanId:scanDetails:errorCode:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) VGSCSDKAInt * _Nullable errorCode __attribute__((swift_name("errorCode")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));
@property (readonly) NSString * _Nullable scanDetails __attribute__((swift_name("scanDetails")));
@property (readonly) NSString * _Nullable scanId __attribute__((swift_name("scanId")));
@property (readonly) VGSCSDKAVGSAnalyticsScannerType *scannerType __attribute__((swift_name("scannerType")));
@property (readonly) VGSCSDKAVGSAnalyticsStatus *status __attribute__((swift_name("status")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsEvent.SecureTextRange")))
@interface VGSCSDKAVGSAnalyticsEventSecureTextRange : VGSCSDKAVGSAnalyticsEvent
- (instancetype)initWithFieldType:(NSString *)fieldType contentPath:(NSString *)contentPath __attribute__((swift_name("init(fieldType:contentPath:)"))) __attribute__((objc_designated_initializer));
- (VGSCSDKAVGSAnalyticsEventSecureTextRange *)doCopyFieldType:(NSString *)fieldType contentPath:(NSString *)contentPath __attribute__((swift_name("doCopy(fieldType:contentPath:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *contentPath __attribute__((swift_name("contentPath")));
@property (readonly) NSString *fieldType __attribute__((swift_name("fieldType")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) VGSCSDKAMutableDictionary<NSString *, id> *params __attribute__((swift_name("params")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) NSString *type __attribute__((swift_name("type")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsMappingPolicy")))
@interface VGSCSDKAVGSAnalyticsMappingPolicy : VGSCSDKAKotlinEnum<VGSCSDKAVGSAnalyticsMappingPolicy *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) VGSCSDKAVGSAnalyticsMappingPolicy *nestedJson __attribute__((swift_name("nestedJson")));
@property (class, readonly) VGSCSDKAVGSAnalyticsMappingPolicy *flatJson __attribute__((swift_name("flatJson")));
@property (class, readonly) VGSCSDKAVGSAnalyticsMappingPolicy *nestedJsonArraysMerge __attribute__((swift_name("nestedJsonArraysMerge")));
@property (class, readonly) VGSCSDKAVGSAnalyticsMappingPolicy *nestedJsonArraysOverwrite __attribute__((swift_name("nestedJsonArraysOverwrite")));
+ (VGSCSDKAKotlinArray<VGSCSDKAVGSAnalyticsMappingPolicy *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<VGSCSDKAVGSAnalyticsMappingPolicy *> *entries __attribute__((swift_name("entries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsScannerType")))
@interface VGSCSDKAVGSAnalyticsScannerType : VGSCSDKAKotlinEnum<VGSCSDKAVGSAnalyticsScannerType *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) VGSCSDKAVGSAnalyticsScannerType *blinkCard __attribute__((swift_name("blinkCard")));
@property (class, readonly) VGSCSDKAVGSAnalyticsScannerType *cardIo __attribute__((swift_name("cardIo")));
+ (VGSCSDKAKotlinArray<VGSCSDKAVGSAnalyticsScannerType *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<VGSCSDKAVGSAnalyticsScannerType *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *analyticsValue __attribute__((swift_name("analyticsValue")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsStatus")))
@interface VGSCSDKAVGSAnalyticsStatus : VGSCSDKAKotlinEnum<VGSCSDKAVGSAnalyticsStatus *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) VGSCSDKAVGSAnalyticsStatus *ok __attribute__((swift_name("ok")));
@property (class, readonly) VGSCSDKAVGSAnalyticsStatus *failed __attribute__((swift_name("failed")));
@property (class, readonly) VGSCSDKAVGSAnalyticsStatus *canceled __attribute__((swift_name("canceled")));
+ (VGSCSDKAKotlinArray<VGSCSDKAVGSAnalyticsStatus *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<VGSCSDKAVGSAnalyticsStatus *> *entries __attribute__((swift_name("entries")));
- (NSString *)getAnalyticsName __attribute__((swift_name("getAnalyticsName()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsUpstream")))
@interface VGSCSDKAVGSAnalyticsUpstream : VGSCSDKAKotlinEnum<VGSCSDKAVGSAnalyticsUpstream *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) VGSCSDKAVGSAnalyticsUpstreamCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) VGSCSDKAVGSAnalyticsUpstream *tokenization __attribute__((swift_name("tokenization")));
@property (class, readonly) VGSCSDKAVGSAnalyticsUpstream *custom __attribute__((swift_name("custom")));
+ (VGSCSDKAKotlinArray<VGSCSDKAVGSAnalyticsUpstream *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<VGSCSDKAVGSAnalyticsUpstream *> *entries __attribute__((swift_name("entries")));
- (NSString *)getAnalyticsName __attribute__((swift_name("getAnalyticsName()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsUpstream.Companion")))
@interface VGSCSDKAVGSAnalyticsUpstreamCompanion : VGSCSDKABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) VGSCSDKAVGSAnalyticsUpstreamCompanion *shared __attribute__((swift_name("shared")));
- (VGSCSDKAVGSAnalyticsUpstream *)getIsTokenization:(BOOL)isTokenization __attribute__((swift_name("get(isTokenization:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("VGSAnalyticsSession")))
@interface VGSCSDKAVGSAnalyticsSession : VGSCSDKABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)vGSAnalyticsSession __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) VGSCSDKAVGSAnalyticsSession *shared __attribute__((swift_name("shared")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Session_iosKt")))
@interface VGSCSDKASession_iosKt : VGSCSDKABase
+ (NSString *)randomUUID __attribute__((swift_name("randomUUID()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface VGSCSDKAKotlinEnumCompanion : VGSCSDKABase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) VGSCSDKAKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface VGSCSDKAKotlinArray<T> : VGSCSDKABase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(VGSCSDKAInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<VGSCSDKAKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol VGSCSDKAKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
