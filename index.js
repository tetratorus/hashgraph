var dgram = require('dgram');
var fs = require('fs');
var EventEmitter = require('events');

var defaultOptions = {
  port: 41234
}

// Hashgraph Consensus Algorithm
// The following is an attempt to implement the algorithm defined in white paper by Leemon Baird
// http://www.swirlds.com/wp-content/uploads/2016/06/SWIRLDS-TR-2016-01.pdf

// events table
// id | publickey | event hash | timestamp (milli) | parent_hash | sender_hash | decided_position
// publickey: the publickey of the node where the event occured
// event hash: hash over (timestamp, parent-hash, sender-hash, pubkey). unique.
// parent_hash: the event that occured on the node before
// sender_hash: the hash of the event that was gossiped and led to the creation of this event
// decided_position: will be assigned a global position (order) as soon as consensus algorithm decided it

// transactions table
// event hash | payload | position

// nodes table
// some-name-readable-for-humans | publickey | address | port | lastactivity (milli) | contract | state (json object)

// data
// key | value

module.exports = function(_options) {
  var options = Object.assign({}, defaultOptions, _options);
  var hashgraph = new EventEmitter();
  var knownNodes = {}
  var socket = dgram.createSocket('udp6');
  var port = options.port;

  // When this gets really big... What happens?
  knownNodes[options.publicKey] = 'localhost:' + port

  socket.bind(port);

  socket.on('error', function(err) {
    console.log(`socket error:\n${err.stack}`);
    socket.close();
  });
  
  socket.on('listening', function() {
    var address = socket.address();
    console.log(`socket listening ${address.address}:${address.port}`);
    hashgraph.emit('ready');
  })
  
  socket.on('message', function (data, fn) {
    // TODO: analyze payload. check if it's malicious (the tx might lock up the VM etc)
    // TODO: consensus algorithm, decide what transactions to execute in what order.
    var transactions = []
    transactions.push(data.toString());
    hashgraph.emit('consensus', transactions);
  });
  
  var currentEvent;
  
  currentEvent = {
      
  }

  function gossip() {
    // TODO: 'finalize' current event (assign hash, save transactions + event in DB)
    // TODO: pick random node
    // TODO: find events and txs that we think that node does not know
    // TODO: send all the events and new transactions to the node with a signature
  }

  function receiveGossip() {
    // TODO: save received events and txs in DB and
    // TODO: merge received events and txs with hashgraph in memory
    // TODO: create new event proving receipt of gossip
    // TODO: 'open up' that event to record new transactions
    consensus();
  }

  function consensus() {
    // TODO: divideRounds
    // TODO: decideFame
    // TODO: findOrder
    // TODO: apply all transactions of events which's order was calculated
  }

  // This is called locally (not from the network) when the user wants to add transaction
  function sendTransaction(payload) {
    // TODO: if there is no 'current recording event', create new event
    // TODO: record the transaction onto the event
    // TODO: after a while, gossip the event
    // TODO: as soon as consensus is reached on the order of this event, apply the transactions
    
    // TODO: replace this code with real consensus algo
    var promises = []
    for (publicKey in knownNodes) {
      promises.push(new Promise(function(resolve) {
        var host = knownNodes[publicKey];
        var ip = host.substr(0, host.lastIndexOf(':'));
        var port = host.substr(host.lastIndexOf(':') + 1);
        socket.send(payload, port, ip, resolve)    
      }))
    }
    return Promise.all(promises).catch(console.error);
  }
  
  
  hashgraph.sendTransaction = function(payload) {
    sendTransaction(payload);
  }
  hashgraph.join = function(ip, publicKey) {
    if (!publicKey) publicKey = ''; // TODO: fetch publicKey from node
    knownNodes[publicKey] = ip;
  }
  
  return hashgraph;
}
