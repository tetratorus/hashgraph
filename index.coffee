EventEmitter = require('events')
IPFS = require('ipfs')
co = require('co')
path = require('path')
os = require('os')
mh = require('multihashes')

# TODO: use javascript ipfs implementation instead of spawning `ipfs`. But jsipfs does not support IPNS.
spawn = require('child_process').spawn

defaultOptions = {
  path: path.join(os.homedir(), '.hashgraph')
}


hashgraph = (_options) ->
  ipfs = null
  options = Object.assign({}, defaultOptions, _options)
  path = options.path
  knownPeerIDs = []
  hashgraph = new EventEmitter()
  myPeerID = ''
  head = ''
  
  
  ########## Private
  publishEvent = (ownParentHash, remoteParentHash, myPeerID, unixTimeMilli, payload) ->
    # ipfs = spawnSync('ipfs', ['object', 'put'])
    object = 
      Data: JSON.stringify(c: myPeerID, t: unixTimeMilli, d: payload)
      Links: [
        {Name: '0', Hash: ownParentHash},
        {Name: '1', Hash: remoteParentHash},
      ]
    # ipfs.stdin.write(JSON.stringify(object))
    # ipfs.stdin.end()
    # ipfs.stdout.read()
    ipfs.object.put(object)
    
  setHead = (eventHash) ->
    head = eventHash
    # TODO: publish in IPNS
  
    
  
  ########### Public
  hashgraph.info = ->
    return {
      peerID: myPeerID,
      head: head
    }
  
  hashgraph.init = ->
    new Promise (resolve, reject) ->    
      console.log("Running hashgraph in #{path}")
      ipfs = new IPFS(path)
      
      ipfs.init {emptyRepo: true}, (err) ->
        throw err if err && err.message.indexOf('already') == -1 # dont treat existing repo as error. just reuse it.
        ipfs.load ->
          ipfs.id().then (result) ->
            myPeerID = result.id
            
            # an Event is a tuple of: ownParentHash, remoteParentHash, myPeerID, time, payload
            publishEvent(null, null, myPeerID, new Date().getTime(), null)
              .then (result) ->
                # result is a mDAGnode
                hash = mh.toB58String(result.multihash())
                setHead(hash)
                hashgraph.emit('ready')
                resolve()
              .catch reject
          
          
      
        
  
  
  hashgraph.sendTransaction = (payload) -> 
    sendTransaction(payload)
  
  hashgraph.join = (peerID) ->
    knownPeerIDs.push(peerID)
    
  return hashgraph


module.exports = hashgraph
