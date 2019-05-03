#import "MoneroWalletAdapter.h"
#import "MoneroTransactionInfoAdapter.h"

#ifndef MoneroWalletHistoryAdapter_h
#define MoneroWalletHistoryAdapter_h

struct MoneroTransactionHistoryMember;

@interface MoneroWalletHistoryAdapter: NSObject
{
    struct MoneroTransactionHistoryMember *member;
}
- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet;
- (int)count;
- (MoneroTransactionInfoAdapter *)transaction:(int) index;
- (NSArray<MoneroTransactionInfoAdapter *> *)getAll;
- (void)refresh;
@end

#endif /* MoneroWalletHistoryAdapter_h */
