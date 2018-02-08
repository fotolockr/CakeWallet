//
//  MoneroWallet.m
//  Wallet
//
//  Created by FotoLockr on 06.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoneroWalletAdapter.h"
#import "wallet/api/wallet.h"
#import "MoneroWalletError.h"
#import "MoneroPendingTransactionAdapter.mm"

using namespace std;

struct MonerWalletListener: Monero::WalletListener {
    MoneroWalletAdapter *wallet;
    
    void moneySpent(const std::string &txId, uint64_t amount) {
        [wallet.delegate moneySpent: [NSString stringWithUTF8String: txId.c_str()] amount: amount];
    }
    
    void moneyReceived(const std::string &txId, uint64_t amount) {
        [wallet.delegate moneyReceived: [NSString stringWithUTF8String: txId.c_str()] amount: amount];
    }
    
    void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) {
        [wallet.delegate unconfirmedMoneyReceived: [NSString stringWithUTF8String: txId.c_str()] amount: amount];
    }
    
    void newBlock(uint64_t height) {
        [wallet.delegate newBlock: height];
    }
    
    void updated() {
        [wallet.delegate updated];
    }
    
    void refreshed() {
        [wallet.delegate refreshed];
    }
};

struct MoneroWalletAdapterMember {
    Monero::WalletImpl *wallet;
    MonerWalletListener *listener;
};

@implementation MoneroWalletAdapter: NSObject

- (id)init
{
    self = [super init];
    if (self) {
        Monero::Utils::onStartup();
        Monero::WalletImpl *wallet = new Monero::WalletImpl(false);
        MonerWalletListener *listener = new MonerWalletListener();
        listener->wallet = self;
        wallet->setListener(listener);
        member = new MoneroWalletAdapterMember();
        member->wallet = wallet;
        member->listener = listener;
    }
    
    return self;
}

- (void)setIsRecovery:(BOOL) isRecovery
{
    member->wallet->setRecoveringFromSeed(isRecovery);
}

- (BOOL)lightWalletLogin: (BOOL) isNewWallet error:(NSError **) error
{
//    bool isLogined = wallet->lightWalletLogin(false);
//
//    if (!isLogined) {
//        if (error != NULL) {
//            NSString* errorDescription = [NSString stringWithUTF8String: wallet->errorString().c_str()];
//            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
//                                         code: MoneroWalletCreatingError
//                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
//        }
//
//        return false;
//    }
//
//    return true;
    
    return false;
}

- (BOOL)generateWithPath:(NSString *)path andPassword:(NSString *)password error:(NSError **) error
{
    string utf8Path = [path UTF8String];
    string utf8Password = [password UTF8String];
    bool isCreated = member->wallet->create(utf8Path, utf8Password, [@"English" UTF8String]);
    
    if (!isCreated) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletCreatingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (BOOL)loadWalletWithPath:(NSString *)path andPassword:(NSString *) password error:(NSError **) error
{
    string utf8Path = [path UTF8String];
    string utf8Password = [password UTF8String];
    bool isOpened = member->wallet->open(utf8Path, utf8Password);
    
    if (!isOpened) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletCreatingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (uint64_t)connectionStatus
{
    try {
        Monero::Wallet::ConnectionStatus status = member->wallet->connected();
        return static_cast<uint64_t>(status);
    } catch (...) {
        return 0;
    }
}

- (NSString *)seed
{
    string seed = member->wallet->seed();
    return [NSString stringWithUTF8String: seed.c_str()];
}

- (NSString *)address
{
    string addr = member->wallet->address();
    return [NSString stringWithUTF8String: addr.c_str()];
}

- (BOOL)recoveryAt:(NSString *)path mnemonic: (NSString *)seed error:(NSError **) error
{
    string utf8Path = [path UTF8String];
    string utf8seed = [seed UTF8String];
    member->wallet->setRecoveringFromSeed(true);
    bool isRecovered = member->wallet->recover(utf8Path, utf8seed);
    
    
    if (!isRecovered) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletRecoveringError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (void)refresh
{
    member->wallet->refresh();
}

- (void)startRefreshAsync
{
    member->wallet->refreshAsync();
    member->wallet->startRefresh();
}

- (MoneroPendingTransactionAdapter *)createTransactionToAddress: (NSString *) address WithPaymentId: (NSString *) paymentId amountStr: (NSString *) amount_str priority: (UInt64) priority error: (NSError *__autoreleasing *) error
{
    uint64_t amount;
    string amountStdString = [amount_str UTF8String];
    string addressStdString = [address UTF8String];
    string paymentIdStdString = [paymentId UTF8String];
    cryptonote::parse_amount(amount, amountStdString);
    uint32_t mixin = member->wallet->defaultMixin();
    
    Monero::PendingTransaction::Priority _priopity = static_cast<Monero::PendingTransaction::Priority>(priority);
    Monero::PendingTransaction *tx = member-> wallet->createTransaction(addressStdString, paymentIdStdString, amount, mixin, _priopity);
    int status = tx->status();
    
    if (status == Monero::PendingTransaction::Status::Status_Error
        || status == Monero::PendingTransaction::Status::Status_Critical) {
        
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: tx->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletTransactionCreatingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return nil;
    }
    
    MoneroPendingTransactionMember *ptxMember = new MoneroPendingTransactionMember();
    ptxMember->tx = tx;
    MoneroPendingTransactionAdapter *ptx = [[MoneroPendingTransactionAdapter alloc] initWithMember: ptxMember];
    
    return ptx;
}

- (BOOL)save: (NSError **) error
{
    bool isSaved = member->wallet->store(member->wallet->path());
    
    if (!isSaved) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletSavingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (BOOL)connectToDaemon: (NSError **) error
{
    bool isConnected = member->wallet->connectToDaemon();
    
    if (!isConnected) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletConnectingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (void)setDaemonAddress: (NSString *) address login: (NSString *) login password: (NSString *) password
{
    string utf8Host = [address UTF8String];
    string loginStdString = [login UTF8String];
    string passwordStdString = [password UTF8String];
    member->wallet->init(utf8Host, 0, loginStdString, passwordStdString, false, false);
}

- (uint64_t)balance
{
    return member->wallet->balance();
}

- (uint64_t)unlockedBalance
{
    return member->wallet->unlockedBalance();
}

- (uint64_t)currentHeight
{
    return member->wallet->blockChainHeight();
}

- (uint64_t)daemonBlockChainHeight
{
    return member->wallet->daemonBlockChainTargetHeight();
}

- (NSString *)errorString
{
    return [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
}

- (NSString *)name
{
    NSString *filename = [NSString stringWithUTF8String: member->wallet->filename().c_str()];
    NSArray *items = [filename componentsSeparatedByString: @"/"];
    return [items lastObject];
}

- (NSString *)printedBalance
{
    uint64_t balance = [self balance];
    return [NSString stringWithUTF8String: cryptonote::print_money(balance).c_str()];
}

- (NSString *)printedUnlockedBalance
{
    uint64_t unlockedBalance = [self unlockedBalance];
    return [NSString stringWithUTF8String: cryptonote::print_money(unlockedBalance).c_str()];
}

- (Monero::TransactionHistory *)rawHistory
{
    return member->wallet->history();
}

- (BOOL)setPassword:(NSString *) password error:(NSError **) error
{
    bool changed = member->wallet->setPassword([password UTF8String]);
    
    if (!changed) {
        if (error != NULL) {
            NSString* errorDescription = [NSString stringWithUTF8String: member->wallet->errorString().c_str()];
            *error = [NSError errorWithDomain: MoneroWalletErrorDomain
                                         code: MoneroWalletPasswordChangingError
                                     userInfo: @{ NSLocalizedDescriptionKey: errorDescription }];
        }
        
        return false;
    }
    
    return true;
}

- (void)close
{
    member->wallet->pauseRefresh();
    member->listener->wallet = NULL;
    member->wallet->setListener(NULL);
    member->wallet->close();
}

- (void)clear
{
    member->listener->wallet = NULL;
    member->wallet->setListener(NULL);
}


- (void)dealloc
{
    delete member->wallet;
    delete member->listener;
    free(member);
}

@end

