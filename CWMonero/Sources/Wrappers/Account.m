#import <Foundation/Foundation.h>
#import "Account.h"

@implementation Account: NSObject

- (instancetype)initWithLabel:(NSString *)label index: (uint32_t) index
{
    self = [super init];
    if (self) {
        if ([label isEqualToString: @"Primary account"]) {
            label = @"Primary";
        }
        
        self.label = label;
        self.index = index;
    }
    
    return self;
}

@end
