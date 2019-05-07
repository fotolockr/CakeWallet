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
- (void)newSubaddressWithLabel:(NSString *) label withAccountIndex:(uint32_t) accountIndex;
- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index withAccountIndex:(uint32_t) accountIndex;
- (NSArray *)getAll;
- (void)refresh:(uint32_t) accountIndex;
@end


#endif /* Subaddresses_h */
