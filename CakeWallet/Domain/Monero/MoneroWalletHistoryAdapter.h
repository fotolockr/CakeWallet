//
//  MoneroWalletHistoryAdapter.h
//  Wallet
//
//  Created by FotoLockr on 09.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

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
