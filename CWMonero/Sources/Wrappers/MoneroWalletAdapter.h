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
   @public struct MoneroWalletAdapterMember *member;
}
@property (weak) id<MoneroWalletAdapterDelegate> delegate;
+ (NSString *) generatePaymentId;
+ (NSData *) cnFastHashForData:(uint8_t *) bytes length:(size_t) length size:(size_t) size;
+ (NSData *) psk:(uint8_t *) bytes;
+ (NSData *) pvk:(uint8_t *) bytes;
+ (NSData *)secretKeyToPublic:(NSData *) secKey;
//+ (NSString *)addressForSpendKey:(NSString *)spendKey andViewKey:(NSString *)viewKey;
+ (NSString *) base58Encode:(NSString *) text;
+ (NSString *) getAddressFromViewKey:(NSData *) viewKeyData AndSpendKey:(NSData *) spendKeyData;
- (id)init;
- (void)setIsRecovery:(BOOL) isRecovery;
- (BOOL)generateWithPath:(NSString *)path andPassword:(NSString *)password error:(NSError **) error;
- (BOOL)loadWalletWithPath:(NSString *)path andPassword:(NSString *) password error:(NSError **) error;
- (BOOL)recoveryAt:(NSString *)path
          mnemonic: (NSString *)seed
       andPassword:(NSString *) password
     restoreHeight: (uint64_t) restoreHeight
             error:(NSError **) error;
- (BOOL)recoveryFromKeyAt:(NSString *) path
            withPublicKey:(NSString *) publicKey
              andPassowrd:(NSString *) password
               andViewKey:(NSString *) viewKey
              andSpendKey:(NSString *) spendKey
        withRestoreHeight:(uint64_t) restoreHeight
                    error:(NSError **) error;
- (BOOL)rescanSpent;
- (uint64_t)connectionStatus;
- (NSString *)seed;
- (NSString *)address;
- (NSString *)secretViewKey;
- (NSString *)publicViewKey;
- (NSString *)secretSpendKey;
- (NSString *)publicSpendKey;
- (void)startRefreshAsync;
- (MoneroPendingTransactionAdapter *)createTransactionToAddress: (NSString *) address WithPaymentId: (NSString *) paymentId amountStr: (NSString *) amount_str priority: (UInt64) priority error: (NSError *__autoreleasing *) error;
- (BOOL)save: (NSError **) error;
- (BOOL)connectToDaemon: (NSError **) error;
- (BOOL)checkConnectionWithTimeout:(uint32_t) timeout;
- (void)setDaemonAddress: (NSString *) address login: (NSString *) login password: (NSString *) password;
- (void)setRefreshFromBlockHeight:(UInt64) height;
- (uint64_t)currentHeight;
- (uint64_t)daemonBlockChainHeight;
- (uint64_t)balance;
- (uint64_t)unlockedBalance;
- (NSString *)errorString;
- (NSString *)name;
- (NSString *)printedBalance;
- (NSString *)printedUnlockedBalance;
- (NSString *)integratedAddressFor: (NSString *) paymentId;
- (NSString *)getTxKeyFor: (NSString *)txId;
- (BOOL)setPassword:(NSString *) password error:(NSError **) error;
- (void)pauseRefresh;
- (void)close;
- (void)clear;
- (BOOL)lightWalletLogin: (BOOL) isNewWallet error:(NSError **) error;
@end



#endif /* MoneroWalletAdapter_h */
