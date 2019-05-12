#import <Foundation/Foundation.h>
#import "MoneroWalletAdapter.h"
#import "wallet/api/wallet.h"
#import "wallet/api/wallet.cpp"
#import "MoneroWalletError.h"
#import "MoneroPendingTransactionAdapter.mm"
#import "crypto/hash.h"
#import "crypto/crypto.h"

#import "crypto/random.h"
#include "include_base_utils.h"
#include "cryptonote_protocol/cryptonote_protocol_handler.h"
#include "cryptonote_basic/cryptonote_format_utils.h"
#include "crypto/crypto-ops.h"
#include "crypto/random.h"
#include "crypto/keccak.h"

#include "common/base58.h"

using namespace epee;
using namespace cryptonote;
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
public:
    Monero::WalletImpl *wallet;
    MonerWalletListener *listener;
};

@implementation MoneroWalletAdapter: NSObject

+ (NSString *) generatePaymentId
{
    NSString *paymentId = [NSString stringWithUTF8String: Monero::Wallet::genPaymentId().c_str()];
    return paymentId;
}

+ (NSData *) cnFastHashForData:(uint8_t *) bytes length:(size_t) length size:(size_t) size
{
    char md[length];
    crypto::cn_fast_hash(bytes, size, md);
    NSData *_data = [NSData dataWithBytes:&md length:length];
    return _data;
}

+ (NSData *) psk:(uint8_t *) bytes
{
    char md[32];
    crypto::cn_fast_hash(bytes, 2 * sizeof(uint64_t), md);
    sc_reduce32(reinterpret_cast<unsigned char *>(&md));
    NSData *_data = [NSData dataWithBytes:&md length:32];
    
    return _data;
}

+ (NSData *) pvk:(uint8_t *) bytes
{
    char _md[32];
    char md[32];
    crypto::cn_fast_hash(bytes, 2 * sizeof(uint64_t), _md);
    crypto::cn_fast_hash(&_md, 4 * sizeof(uint64_t), md);
    sc_reduce32(reinterpret_cast<unsigned char *>(&md));
    NSData *_data = [NSData dataWithBytes:&md length:32];
    
    return _data;
}

+ (NSData *)secretKeyToPublic:(NSData *) secKeyData
{
    crypto::secret_key skey = *reinterpret_cast<const crypto::secret_key*>([secKeyData bytes]);
    crypto::public_key pkey;
    
    if (!crypto::secret_key_to_public_key(skey, pkey))
        return NULL; // fixme
    
    NSData *pubKeyData = [NSData dataWithBytes:&pkey length:32];
    return pubKeyData;
}

//+ (NSString *)addressForSpendKey:(NSString *)spendKey andViewKey:(NSString *)viewKey
//{
//    long netbyte = 12;
//    NSString *preAddress = [NSString stringWithFormat:@"%@%@%@",[@(netbyte) stringValue], spendKey, viewKey];
//    NSData *preAddressData = [preAddress dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *hashData = [self cnFastHashForData:(uint8_t *)[preAddressData bytes] length:[preAddressData length]];
//    NSString *hash = [[NSString alloc] initWithData:hashData encoding:NSUTF8StringEncoding];
//    NSString *address = [NSString stringWithUTF8String: tools::base58::encode([hash UTF8String]).c_str()];
//    return address;
//}

+ (NSString *) base58Encode:(NSString *) text
{
    return  [NSString stringWithUTF8String: tools::base58::encode([text UTF8String]).c_str()];
}

+ (NSString *) getAddressFromViewKey:(NSData *) viewKeyData AndSpendKey:(NSData *) spendKeyData
{
    cryptonote::account_public_address addr = cryptonote::account_public_address();
    addr.m_spend_public_key = *reinterpret_cast<const crypto::public_key*>([spendKeyData bytes]);
    addr.m_view_public_key = *reinterpret_cast<const crypto::public_key*>([viewKeyData bytes]);
    std::string _address = cryptonote::get_account_address_as_str(cryptonote::MAINNET, false, addr);
    
    return  [NSString stringWithUTF8String: _address.c_str()];
}

- (id)init
{
    self = [super init];
    if (self) {
        Monero::Utils::onStartup();
        Monero::WalletImpl *wallet = new Monero::WalletImpl(Monero::NetworkType::MAINNET, 1);
        MonerWalletListener *listener = new MonerWalletListener();
        listener->wallet = self;
        wallet->setListener(listener);
        member = new MoneroWalletAdapterMember();
        member->wallet = wallet;
        member->listener = listener;
        Monero::WalletManagerFactory::setLogLevel(-1);
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
        if(member->wallet != NULL)
        {
            Monero::Wallet::ConnectionStatus status = member->wallet->connected();
            return static_cast<uint64_t>(status);
        }
        
        return 0;
    } catch (...) {
        return 0;
    }
}

- (NSString *)seed
{
    string seed = member->wallet->seed();
    return [NSString stringWithUTF8String: seed.c_str()];
}

- (NSString *)addressFor: (uint32_t) accountIndex addressIndex: (uint32_t) addressIndex
{
    string addr = member->wallet->address(accountIndex, addressIndex);
    return [NSString stringWithUTF8String: addr.c_str()];
}


- (BOOL) checkConnectionWithTimeout:(uint32_t) timeout
{
    try {
        Monero::Wallet::ConnectionStatus status = member->wallet->connected();
        return static_cast<uint64_t>(status);
    } catch (...) {
        return NO;
    }
}

- (BOOL)recoveryAt:(NSString *)path mnemonic: (NSString *)seed andPassword:(NSString *) password restoreHeight: (uint64_t) restoreHeight error:(NSError **) error
{
    string utf8Path = [path UTF8String];
    string utf8seed = [seed UTF8String];
    string utf8password = [password UTF8String];
    
    member->wallet->setRecoveringFromSeed(true);
    
    if(restoreHeight > 0) {
        member->wallet->setRefreshFromBlockHeight(restoreHeight);
    }
    
    bool isRecovered = member->wallet->recover(utf8Path, utf8password, utf8seed);
    
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

- (void)setRefreshFromBlockHeight:(UInt64) height
{
    member->wallet->setRefreshFromBlockHeight(height);
}

- (BOOL)rescanSpent
{
    member->wallet->setTrustedDaemon(true);
    return member->wallet->rescanSpent();
}

- (BOOL)recoveryFromKeyAt:(NSString *) path
            withPublicKey:(NSString *) publicKey
              andPassowrd:(NSString *) password
               andViewKey:(NSString *) viewKey
              andSpendKey:(NSString *) spendKey
        withRestoreHeight:(uint64_t) restoreHeight
                    error:(NSError **) error
{
    string pathStdString = [path UTF8String];
    string publicKeyStdString = [publicKey UTF8String];
    string viewKeyStdString = [viewKey UTF8String];
    string spendKeyStdString = [spendKey UTF8String];
    string passwordStdString = [password UTF8String];
    
    if(restoreHeight > 0){
        member->wallet->setRefreshFromBlockHeight(restoreHeight);
    }
    
    bool isRecovered = member->wallet->recoverFromKeysWithPassword(pathStdString, passwordStdString, [@"English" UTF8String], publicKeyStdString, viewKeyStdString, spendKeyStdString);
    
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

- (MoneroPendingTransactionAdapter *)createTransactionToAddress: (NSString *) address WithPaymentId: (NSString *) paymentId amountStr: (NSString *) amount_str priority: (UInt64) priority accountIndex: (uint32_t) accountIndex error: (NSError *__autoreleasing *) error
{
    
    string addressStdString = [address UTF8String];
    string paymentIdStdString = [paymentId UTF8String];
    uint32_t mixin = member->wallet->defaultMixin();
    std::set<uint32_t> subaddr_indices;
    Monero::PendingTransaction::Priority _priopity = static_cast<Monero::PendingTransaction::Priority>(priority);
    Monero::PendingTransaction *tx;
    
    if (amount_str != nil) {
        uint64_t amount;
        string amountStdString = [amount_str UTF8String];
        cryptonote::parse_amount(amount, amountStdString);
        tx = member-> wallet->createTransaction(addressStdString, paymentIdStdString, amount, mixin, _priopity, accountIndex, subaddr_indices);
    } else {
        tx = member-> wallet->createTransaction(addressStdString, paymentIdStdString, Monero::optional<uint64_t>(), mixin, _priopity, accountIndex, subaddr_indices);
    }
    
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
        if (error != NULL && member->wallet != NULL) {
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

- (uint64_t)balanceFor: (uint32_t) account
{
    return member->wallet->balance(account);
}

- (uint64_t)unlockedBalanceFor: (uint32_t) account
{
    return member->wallet->unlockedBalance(account);
}

- (uint64_t)currentHeight
{
    return member->wallet->blockChainHeight();
}

- (NSString *)secretViewKey
{
    NSString *secretViewKey = [NSString stringWithUTF8String: member->wallet->secretViewKey().c_str()];
    return secretViewKey;
}

- (NSString *)publicViewKey
{
    NSString *publicViewKey = [NSString stringWithUTF8String: member->wallet->publicViewKey().c_str()];
    return publicViewKey;
}

- (NSString *)secretSpendKey
{
    NSString *secretSpendKey = [NSString stringWithUTF8String: member->wallet->secretSpendKey().c_str()];
    return secretSpendKey;
}

- (NSString *)publicSpendKey
{
    NSString *publicSpendKey = [NSString stringWithUTF8String: member->wallet->publicSpendKey().c_str()];
    return publicSpendKey;
}

- (uint64_t)daemonBlockChainHeight
{
    try {
        return member->wallet->daemonBlockChainHeight();
    } catch (...) {
        return 0;
    }
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

- (NSString *)integratedAddressFor: (NSString *) paymentId
{
    string paymentIdUTF8 = [paymentId UTF8String];
    NSString *intAddress = [NSString stringWithUTF8String: member->wallet->integratedAddress(paymentIdUTF8).c_str()];
    return intAddress;
}

- (Monero::TransactionHistory *)rawHistory
{
    return member->wallet->history();
}

- (NSString *)getTxKeyFor: (NSString *)txId
{
    string txIdUTF8 = [txId UTF8String];
    NSString *key = [NSString stringWithUTF8String: member->wallet->getTxKey(txIdUTF8).c_str()];
    return key;
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

- (void)pauseRefresh
{
    member->wallet->pauseRefresh();
}

- (void)close
{
    member->wallet->pauseRefresh();
    member->wallet->close(true);
}

- (void)clear
{
    member->wallet->setListener(NULL);
    member->listener->wallet = NULL;
    member->listener = NULL;
    member->wallet = NULL;
}


- (void)dealloc
{
    delete member->wallet;
    delete member->listener;
    free(member);
}

@end


