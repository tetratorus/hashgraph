# Hashgraph

This is a [hashgraph](https://en.wikipedia.org/wiki/Hashgraph) implementation written in javascript. It is currently in development and not yet ready to be used.

## Get Started

You can use hashgraph for any javascript project that is run on several nodes that require some kind of consensus. For example for a replicated log, or state machine.

### Install Hashgraph

First, install the hashgraph package.

    npm install hashgraph --save
    
### Key Generation

Each node in the hashgraph requires its own public/private keypair. It is using standard [RFC 4716](https://tools.ietf.org/html/rfc4716#section-3.4) keys.

Run the following commands to create a public/private keypair:

    openssl genrsa -out private_key.pem 2048
    openssl rsa -in private_key.pem -pubout -out public_key.pem
    
If you want to protect your private key with a passphrase, use:

    openssl genrsa -passout pass:mypassphrase -out private_key.pem 2048
    openssl rsa -in private_key.pem -passin pass:mypassphrase -pubout -out public_key.pem
    
NOTE: Do not lose your private key file or forget your passphrase. If you do, you will lose all value stored under your public key.

### Set up a node

Once you created your keys, you can set up a node and optionally join another node on the network very easily. 

    var myPublicKey = fs.readFileSync('./public_key.pem').toString();
    var myPrivateKey = fs.readFileSync('./private_key.pem').toString();
    
    var hashgraph = require('hashgraph')({
      database: 'postgresql://localhost/hashgraph',
      publicKey: myPublicKey,
      privateKey: myPrivateKey,
      passphrase: 'somePassPhrase' // optional
    });
    
    // Optionally, join another node on the network
    hashgraph.join(someIPv6Address);

### Maintain consensus

After joining another node on the network you can submit transactions to the network like this:

    hashgraph.on('ready', function() {
      hashgraph.sendTransaction('somePayload');
    })
    
After the transaction has been sent to the network, it will try to achieve consensus over the question where to place this transaction in the global order of all transactions in the network. Once consensus has been achieved, the hashgraph will emit an event that you can listen to:

    hashgraph.on('consensus', function(transactions) {
      // Apply transactions to state machine
    })

This is all you need to know to use hashgraph with your own projects. Read on for information on how to use the [hashgraph ledger](http://github.com/buhrmi/hashgraph-ledger).
