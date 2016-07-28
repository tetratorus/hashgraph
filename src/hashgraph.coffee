window.Visualizer = {
  machines: []
}
Visualizer.addMachine = (node) ->
  Visualizer.machines.push(node)
Visualizer.sendMessage = (fromMachine, toMachine, message, duration = 1000 + Math.random() * 2000) ->
  onArrive = ->
    toMachine.receiveMessage(message, fromMachine) # Usually, the receiver would figure out the "fromMachine" from the message signature. But we're not using PKI in this demo.
    draw()
    messageCircle.remove()
  toX = toMachine.position.left + toMachine.dimensions.width / 2
  toY = toMachine.position.top + 6
  fromX = fromMachine.position.left + fromMachine.dimensions.width / 2
  fromY = fromMachine.position.top + 6
  messageCircle = Visualizer.circle(fromX, fromY, 15)
  messageCircle.animate {transform: ["T",toX-fromX,toY-fromY]}, duration
  delay duration, onArrive

makeMachine = (name, nodes) ->
  machine = {}
  knownMachines = {}
  events = []
  
  gossip = ->
    return alert("Dont know any machines. Cant gossip") if Object.keys(knownMachines).length == 1
    until receiver and receiver.name != name
      randomName = Object.keys(knownMachines)[Math.floor(Math.random()*Object.keys(knownMachines).length)]
      receiver = knownMachines[randomName]
    eventsToSend = []
    for event in events
      eventsToSend.push node: event.node, hash: event.hash, parentHash: event.parentHash, time: event.time, fromHash: event.fromHash
    Visualizer.sendMessage(machine, receiver, JSON.stringify(eventsToSend))
  
  receiveMessage = (message) ->
    receivedEvents = JSON.parse(message)
    learnedSomething = false
    for receivedEvent in receivedEvents
      old = false
      fromNodeName = receivedEvent.node
      unless knownMachines[fromNodeName]
        for possibleMachine in Visualizer.machines
          if possibleMachine.name == fromNodeName
            knownMachines[fromNodeName] = possibleMachine 
      for event in events
        if event.hash == receivedEvent.hash  
          old = true 
          break
      continue if old
      events.push(receivedEvent)
      receivedEvent.selfParent = findEvent(receivedEvent.parentHash)
      receivedEvent.otherParent = findEvent(receivedEvent.fromHash)
      learnedSomething = true
    return unless learnedSomething
    
    newEvent = {node: machine.name, hash: Math.random(), parentHash: getLastEventFrom(name).hash, fromHash: getLastEventFrom(fromNodeName).hash, time: new Date()}
    events.push(newEvent)
    consensus()
    
  getLastEventFrom = (nodeName) ->
    lastEvent = null
    lastEvent = event for event in events when event.node == nodeName
    lastEvent
    
  findEvent = (hash) ->
    return event for event in events when event.hash == hash
  
  consensus = ->
    divideRounds()
    
  divideRounds = ->
    for x in events
      continue if x.round
      determineRound(x)
  
  determineRound = (x) ->
    unless x.parentHash
      x.round = 1
      x.witness = true
      return
    
    parent1 = findEvent(x.parentHash)
    determineRound(parent1) unless parent1.round
    parent2 = findEvent(y.fromHash)
    determineRound(parent2) unless parent2.round
    
    see = []
    stronglySee = []
    
    # TODO: move down ancestor tree and build a list of events that can be strongly seen
    
    
    x.witness = x.round > findEvent(x.parentHash).round && x.round > findEvent(x.fromHash).round
  
  canStronglySee = (x, y) ->
    
  
  canSee = (x, y) ->
    # XXX: In a better implementation, we would search upwards from Y instead downwards from X
    return true if (x.parentHash == y.hash) || (x.fromHash == y.hash)
    # TODO: handle forks
    return false unless x.parentHash
    return canSee(findEvent(x.parentHash), y) || canSee(findEvent(x.fromHash), y)
    
  
  Object.assign machine, 
    name: name,
    gossip: gossip,
    receiveMessage: receiveMessage,
    events: events,
    knownMachines: knownMachines,
    findEvent: findEvent
    
  events.push(node: machine.name, hash: Math.random(), time: new Date(), txs: ['createme'])
  
  
  
  return machine


height = 800
machineHeight = 220
width = 600
eventWidth = 30
topOffset = 20
paddingLeft = 150
circles = {}
draw = ->
  for machine, machineIndex in Visualizer.machines
    machine.set.remove() if machine.set
    machine.set = Visualizer.set()
    machineAngle = machineIndex * 2 * Math.PI / Visualizer.machines.length  
    machineWidth = Object.keys(machine.knownMachines).length * eventWidth + eventWidth    
    machineX = (1+Math.cos(-machineAngle-Math.PI)) * width / 2 - eventWidth - machineWidth / 2 + paddingLeft
    machineY = (1+Math.sin(-machineAngle)) * (height-machineHeight) / 2
    machine.position = {left: machineX, top: machineY}
    machine.dimensions = {width: machineWidth, height: machineHeight}
    rect = Visualizer.rect(machineX, machineY+topOffset, machineWidth, machineHeight)
    rect.attr(stroke: '#ccc', fill: '#fafafa')
    machine.set.push(rect)
    text = Visualizer.text(machineX+machineWidth/2, machineY + 8, machine.name)
    machine.set.push(text)
    timelineStartY = machineY + machineHeight - 20
    index = 0
    for name, knownMachine of machine.knownMachines
      path = Visualizer.path("M #{machineX + eventWidth + index * eventWidth},#{timelineStartY} l 0,#{-machineHeight+topOffset+20}")
      path.attr stroke: '#333'
      machine.set.push(path)
      text = Visualizer.text(machineX + eventWidth + index * eventWidth, machineY+machineHeight, name)
      machine.set.push(text)
      index += 1
    for event, eventIndex in machine.events
      eventX = machineX + eventWidth + Object.keys(machine.knownMachines).indexOf(event.node) * eventWidth
      circle = Visualizer.circle(eventX, timelineStartY - 22 * eventIndex, 10)
      circle.attr("fill", "#EEE")
      circle.attr("stroke", "#333")
      if event.fromHash
        fromEvent = machine.findEvent(event.fromHash)
        if fromEvent && circles[fromEvent.hash]
          path = "M #{circles[fromEvent.hash].attr('cx')},#{circles[fromEvent.hash].attr('cy')} L #{circle.attr('cx')} #{circle.attr('cy')}"
          machine.set.push(Visualizer.path(path))
      circles[event.hash] = circle
      machine.set.push(circle)


  # tetronimo = viz.path("M 250 250 l 0 -50 l -50 0 l 0 -50 l -50 0 l 0 50 l -50 0 l 0 50 z");
  # tetronimo.attr(
  #     {
  #         gradient: '90-#526c7a-#64a0c1',
  #         stroke: '#3b4449',
  #         'stroke-width': 10,
  #         'stroke-linejoin': 'round',
  #         transform: 'r90'        
  #     }
  # )
  
  
  
names = ['Alice', 'Bob', 'Charly', 'Dan', 'Eve', 'Fred', 'Gus', 'Henry', 'Ivy', 'Jim']
$ ->
  Visualizer.__proto__ = Raphael(document.getElementById('hashgraph_visualizer'))
  $('button#add_node').click ->
    name = names[Visualizer.machines.length]
    newMachine = makeMachine(name)
    Visualizer.addMachine(newMachine)
    for machine in Visualizer.machines
      newMachine.knownMachines[machine.name]= machine
    draw()
    $('#log')[0].innerHTML += "#{name} initialized with #{Object.keys(newMachine.knownMachines).length} nodes.\n"
    $("<button>Make #{name} gossip</button>").appendTo($('#gossips')).click ->
      newMachine.gossip()
  
  $('button#add_node').click()
  $('button#add_node').click()

delay = (t, fn) ->
  setTimeout fn, t
