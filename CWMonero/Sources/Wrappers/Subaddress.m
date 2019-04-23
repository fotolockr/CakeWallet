#import <Foundation/Foundation.h>
#import "Subaddress.h"


@implementation Subaddress: NSObject
NSString *address;
NSString *label;

- (instancetype)initWithAddress:(NSString *)address andLabel:(NSString *)label index: (uint32_t) index

{
    self = [super init];
    if (self) {
        self.address = address;
        
        if ([label isEqualToString: @"Primary account"]) {
            label = @"Primary";
        }
        
        self.label = label;
        self.index = index;
    }
    
    return self;
}

@end
