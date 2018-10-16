#import <Foundation/Foundation.h>

#ifndef MoneroAmountParser_h
#define MoneroAmountParser_h

@interface MoneroAmountParser: NSObject
@property (nonatomic) uint64_t value;
+ (NSString *) formatValue: (uint64_t) value;
+ (uint64_t) amountFromString: (NSString *) str;
@end

#endif /* MoneroAmountParser_h */
