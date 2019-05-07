#ifndef Accounts_h
#define Accounts_h

#import <Foundation/Foundation.h>
#import "MoneroTransactionInfoAdapter.h"

struct AccountsMember;

@interface Accounts: NSObject
{
    struct AccountsMember *member;
}
- (instancetype)initWithWallet:(MoneroWalletAdapter *) wallet;
- (void)newAccountWithLabel:(NSString *) label;
- (void)setLabel:(NSString *)label AtIndex:(uint32_t)index;
- (NSArray *)getAll;
- (void)refresh;
@end

#endif /* Accounts_h */
