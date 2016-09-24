# TODO: replace with the js ipfs implementation

spawn = require('child_process').spawn

run = (args, input) ->
  new Promise (resolve, reject) ->
    process = spawn('ipfs', args)
    out = ''
    process.stderr.on 'data', (data) ->
      reject data.toString()
    process.stdout.on 'data', (data) ->
      out += data.toString()
    process.on 'exit', (code) ->      
      if code == 0
        resolve(out) 
      if code == 1
        reject(out)
    process.stdin.write(input) if input
    process.stdin.end()


ipfs = (path) ->
  process.env.IPFS_PATH = path
  
  publish: (value) ->
    run(['name', 'publish', value])
  
  getPublished: (name) ->
    new Promise (resolve, reject) ->
      run(['name', 'resolve', name])
        .then (out) ->
          resolve(out.replace('/ipfs/','').replace('\n',''))
        .catch reject
  
  putObject: (data) ->
    new Promise (resolve, reject) ->
      run(['object', 'put'], data)
        .then (out) ->
          console.log('RESOLVING YO')
          resolve(out.replace('added ','').replace('\n',''))
        .catch ->
          console.log('REJECTING YOU')
          reject()
  
  getPeerInfo: ->
    new Promise (resolve, reject) ->
      run(['id'])
        .then (out) ->
          resolve(JSON.parse(out))
        .catch -> resolve(false)
        
  init: ->
    run(['init'])
    

    
module.exports = ipfs
