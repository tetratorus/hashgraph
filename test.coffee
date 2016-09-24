hashgraph = require('hashgraph')()

hashgraph.init().catch console.error

hashgraph.on 'ready', ->
  console.log hashgraph.info()
