hashgraph = require('hashgraph')()

hashgraph.init()

hashgraph.on 'ready', ->
  console.log hashgraph.info()
