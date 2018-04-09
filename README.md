# Installation

1. Clone the repository.
```sh
git clone https://github.com/fotolockr/CakeWallet.git
```
2. Run install.sh. It's bash script for download and build monero library from sources. Script will download and compile: Boost, OpenSSL and Monero library (as static library) for iOS.
```sh
./install.sh
```
3. Install dependencies from Pod.
```sh
pod install
```

# P.S.

> Also you'll be needed additional headers for build like: *sys/vmmeter.h, netinet/udp_var.h, netinet/ip_var.h, IOKit, [zmq.hpp](https://github.com/zeromq/cppzmq)*.

> We use forked repositories of [ofxiOSBoost](https://github.com/fotolockr/ofxiOSBoost), [monero](https://github.com/fotolockr/monero) and [monero-gui](https://github.com/fotolockr/monero-gui). We do this ONLY for more convenient installation process. Changes which we did in [ofxiOSBoost](https://github.com/fotolockr/ofxiOSBoost), [monero](https://github.com/fotolockr/monero) and [monero-gui](https://github.com/fotolockr/monero-gui) you can see in commit history in "build" branch of these repositories.

**Cake Technologies LLC.**
