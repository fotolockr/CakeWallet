#ifndef Account_h
#define Account_h

#import <Foundation/Foundation.h>

@interface Account: NSObject
- (instancetype)initWithLabel:(NSString *)label index: (uint32_t) index;
@property uint32_t index;
@property (nonatomic, retain) NSString *label;
@end

#endif /* Account_h */
