//
//  MoneroWallet.h
//  Wallet
//
//  Created by FotoLockr on 06.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoneroPendingTransactionAdapter.h"

#ifndef MoneroWalletAdapter_h
#define MoneroWalletAdapter_h

@protocol MoneroWalletAdapterDelegate
@required
- (void)newBlock:(uint64_t) block;
- (void)updated;
- (void)refreshed;
- (void)moneyReceived:(NSString *) txId amount:(uint64_t) amount;
- (void)moneySpent:(NSString *) txId amount:(uint64_t) amount;
- (void)unconfirmedMoneyReceived:(NSString *) txId amount:(uint64_t) amount;
@end

@interface MoneroWalletAdapter: NSObject
{
    struct MoneroWalletAdapterMember *member;
}
@property (weak) id<MoneroWalletAdapterDelegate> delegate;
- (id)init;
- (void)setIsRecovery:(BOOL) isRecovery;
- (BOOL)generateWithPath:(NSString *)path andPassword:(NSString *)password error:(NSError **) error;
- (BOOL)loadWalletWithPath:(NSString *)path andPassword:(NSString *) password error:(NSError **) error;
- (BOOL)recoveryAt:(NSString *)path mnemonic: (NSString *)seed error:(NSError **) error;
- (uint64_t)connectionStatus;
- (NSString *)seed;
- (NSString *)address;
- (void)startRefreshAsync;
- (MoneroPendingTransactionAdapter *)createTransactionToAddress: (NSString *) address WithPaymentId: (NSString *) paymentId amountStr: (NSString *) amount_str priority: (UInt64) priority error: (NSError *__autoreleasing *) error;
- (BOOL)save: (NSError **) error;
- (BOOL)connectToDaemon: (NSError **) error;
- (void)setDaemonAddress: (NSString *) address login: (NSString *) login password: (NSString *) password;
- (uint64_t)currentHeight;
- (uint64_t)daemonBlockChainHeight;
- (uint64_t)balance;
- (uint64_t)unlockedBalance;
- (NSString *)errorString;
- (NSString *)name;
- (NSString *)printedBalance;
- (NSString *)printedUnlockedBalance;
- (BOOL)setPassword:(NSString *) password error:(NSError **) error;
- (void)close:(BOOL) store;
- (BOOL)lightWalletLogin: (BOOL) isNewWallet error:(NSError **) error;
@end



#endif /* MoneroWalletAdapter_h */
