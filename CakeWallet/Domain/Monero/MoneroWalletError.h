//
//  MoneroWalletError.h
//  Wallet
//
//  Created by Cake Technologies 07.10.17.
//  Copyright © 2017 Cake Technologies. 
//

#ifndef MoneroWalletError_h
#define MoneroWalletError_h

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const MoneroWalletErrorDomain;

enum {
    MoneroWalletCreatingError = 1000,
    MoneroWalletLoadingError,
    MoneroWalletRecoveringError,
    MoneroWalletSavingError,
    MoneroWalletConnectingError,
    MoneroWalletPasswordChangingError,
    MoneroWalletTransactionCreatingError
};

#endif /* MoneroWalletError_h */
