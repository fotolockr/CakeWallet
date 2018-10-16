#import "MoneroWalletAdapter.h"
#import "MoneroTransactionInfoAdapter.h"

#ifndef MoneroWalletHistoryAdapter_h
#define MoneroWalletHistoryAdapter_h

@interface MoneroWalletHistoryAdapter: NSObject
- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet;
- (int)count;
- (MoneroTransactionInfoAdapter *)transaction:(int) index;
- (NSArray<MoneroTransactionInfoAdapter *> *)getAll;
- (void)refresh;
@end

#endif /* MoneroWalletHistoryAdapter_h */
