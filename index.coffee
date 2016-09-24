EventEmitter = require('events')
# IPFS = require('ipfs')
co = require('co')
path = require('path')
os = require('os')
# mh = require('multihashes')

# TODO: use javascript ipfs implementation instead of spawning `ipfs`. But jsipfs does not support IPNS.
spawn = require('child_process').spawn

defaultOptions = {
  path: path.join(os.homedir(), '.hashgraph')
}


hashgraph = (_options) ->
  options = Object.assign({}, defaultOptions, _options)
  path = options.path
  knownPeerIDs = []
  hashgraph = new EventEmitter()
  ipfs = null
  myPeerID = null
  head = null
  
  
  ########## Private
  publishEvent = (ownParentHash, otherParentHash, myPeerID, unixTimeMilli, payload) ->
    object = {}
    object.Data = JSON.stringify(c: myPeerID, t: unixTimeMilli, d: payload)
    object.Links = []
    object.Links.push({Name: '0', Hash: ownParentHash}) if ownParentHash
    object.Links.push({Name: '1', Hash: otherParentHash}) if otherParentHash
    ipfs.putObject(JSON.stringify(object))
    
  setHead = (eventHash) ->
    new Promise (resolve, reject) ->
      ipfs.publish(eventHash)
        .then ->
          head = eventHash
          resolve()
        .catch reject
  
  getHead = (peerID = myPeerID) ->
    ipfs.getPublished(peerID)
    
  
  ########### Public
  hashgraph.info = ->
    return {
      peerID: myPeerID,
      head: head
    }
  
  hashgraph.init = ->
    ipfs = require('./go-ipfs-adapter')(path)
    return new Promise (resolve, reject) ->    
      resolve(hashgraph) if myPeerID      
      co ->
        info = yield ipfs.getPeerInfo()
        if info
          console.log("Using Hashgraph Repo found in #{path}")
          myPeerID = info.ID
          getHead(myPeerID)
            .then (hash) ->
              head = hash
              hashgraph.emit('ready')
              resolve(hashgraph)
            .catch reject

        else
          console.log("Initializing a new Hashgraph Repo in #{path}")
          yield ipfs.init()
          info = yield ipfs.getPeerInfo()
          myPeerID = info.ID
          hash = yield publishEvent(null, null, myPeerID, new Date().getTime() / 1000, null)
          yield setHead(hash)
          hashgraph.emit('ready')
          resolve(hashgraph)
            
          
  hashgraph.sendTransaction = (payload) -> 
    sendTransaction(payload)
  
  hashgraph.join = (peerID) ->
    knownPeerIDs.push(peerID)
  
  
  return hashgraph


module.exports = hashgraph
