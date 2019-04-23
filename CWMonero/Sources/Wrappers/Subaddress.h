#ifndef Subaddress_h
#define Subaddress_h

#import <Foundation/Foundation.h>

@interface Subaddress: NSObject
- (instancetype)initWithAddress:(NSString *)address andLabel:(NSString *)label index: (uint32_t) index;
@property uint32_t index;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *label;
@end

#endif /* Subaddress_h */
