#import <Foundation/Foundation.h>
#import "MoneroWalletHistoryAdapter.h"
#import "wallet/api/wallet.h"
#import "wallet/api/transaction_history.h"
#import "MoneroWalletAdapter.h"
#import "MoneroTransactionInfoAdapter.mm"
#import "MoneroWalletAdapter.mm"
#import "Subaddresses.mm"
#import "Accounts.mm"

struct MoneroTransactionHistoryMember {
    Monero::TransactionHistory *transactionHistory;
};

@implementation MoneroWalletHistoryAdapter: NSObject


- (instancetype)initWithWallet: (MoneroWalletAdapter *) wallet
{
    self = [super init];
    if (self) {
        member = new MoneroTransactionHistoryMember();
        member->transactionHistory = [wallet rawHistory];
//        transactionHistory = [wallet rawHistory];
    }
    return self;
}

- (int)count
{
    return member->transactionHistory->count();
}

- (MoneroTransactionInfoAdapter *)transaction:(int) index
{
    Monero::TransactionInfo *_tx = member->transactionHistory->transaction(index);
    MoneroTransactionInfoMember *txMember = new MoneroTransactionInfoMember();
    txMember->tx = _tx;
    MoneroTransactionInfoAdapter *tx = [[MoneroTransactionInfoAdapter alloc] initWithMember: txMember];
    return tx;
}

- (NSArray<MoneroTransactionInfoAdapter *> *)getAll
{
    NSMutableArray<MoneroTransactionInfoAdapter *> *_arr = [[NSMutableArray alloc] init];
    vector<Monero::TransactionInfo *> txs = member->transactionHistory->getAll();
    
    for (auto &originalTx : txs) {
        if (originalTx == NULL)
        {
            continue;
        }
        
        MoneroTransactionInfoMember *txMember = new MoneroTransactionInfoMember();
        txMember->tx = originalTx;
        MoneroTransactionInfoAdapter *tx = [[MoneroTransactionInfoAdapter alloc] initWithMember: txMember];
        [_arr addObject: tx];
    }
    
    return _arr;
}

- (void)refresh
{
    member->transactionHistory->refresh();
}
@end

