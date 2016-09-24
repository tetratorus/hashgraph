# Hashgraph

This is a [hashgraph](https://en.wikipedia.org/wiki/Hashgraph) implementation written in javascript. It is currently in development and not yet ready to be used. This implementation uses [IPFS](http://ipfs.io) as storage and networking backend.

The goal is a hashgraph impelementation that can be used in any javascript project that is run on several nodes that require some kind of consensus. For example for a replicated log, or state machine.

## Get Started

### Installation

The javascript implementation of IPFS is not yet fully featured (IPNS is missing). For now, this project depends on the go-lang implementation to be installed. If you're using Ubuntu, you can use this script to install it:

    curl https://raw.githubusercontent.com/buhrmi/hashgraph/master/install.sh | sh

Then install NPM and the hashgraph package:

    npm install hashgraph --save
    
The javascript IPFS implementation seems to depend on some packages that are not automatically installed. Install them, too:

    npm install -g lodash.isfunction pull-defer readable-stream tar-stream
    
### Usage

In your node application, you can create a new hashgraph node like so:

    hashgraph = require('hashgraph')(options)
    hashgraph.init()

Supported options are:

* path: The path to the hashgraph repository. This is an IPFS repository that stores your private key pair and a local copy of the hashgraph data. Default: `~/.hashgraph`

You can access information about your own hashgraph peer:

    hashgraph.on('ready', function() {
      console.log(hashgraph.info())
    })

The `info()` method returns an object with the following properties:

* `peerID`: Your own peer ID.
* `head`: The Hash of the last event recorded by your peer.

It's a little bit boring to run the network only with one node. You can join another peer like so:

    hashgraph.join(remotePeerID)

After joining another node on the network you can submit transactions to the network like this:

    hashgraph.on('ready', function() {
      hashgraph.sendTransaction('somePayload');
    })
    
After the transaction has been sent to the network, it will try to achieve consensus over the question where to place this transaction in the global order of all transactions in the network. Once consensus has been achieved, the hashgraph will emit an event that you can listen to:

    hashgraph.on('consensus', function(transactions) {
      // Apply transactions to state machine
    })

This is all you need to know to use hashgraph with your own projects. Read on for information on how to use the [hashgraph ledger](http://github.com/buhrmi/hashgraph-ledger).
