#ifndef Subaddresses_h
#define Subaddresses_h

#import <Foundation/Foundation.h>
#import "MoneroTransactionInfoAdapter.h"

struct SubaddressesMember;

@interface Subaddresses: NSObject
{
    struct SubaddressesMember *member;
}
- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet;
- (void)newSubaddressWithLabel:(NSString *) label;
- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index;
- (NSArray *)getAll;
- (void)refresh;
@end


#endif /* Subaddresses_h */
