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
    
    Visualizer.sendMessage(machine, receiver, JSON.stringify(events))
  
  receiveMessage = (message) ->
    receivedEvents = JSON.parse(message)
    for receivedEvent in receivedEvents
      fromNodeName = receivedEvent.node
      unless knownMachines[fromNodeName]
        for possibleMachine in Visualizer.machines
          if possibleMachine.name == fromNodeName
            knownMachines[fromNodeName] = possibleMachine 
          
    
  
  Object.assign machine, 
    name: name,
    gossip: gossip,
    receiveMessage: receiveMessage,
    events: events,
    knownMachines: knownMachines
    
  events.push({node: machine.name, hash: Math.random()})
  
  
  
  return machine


height = 800
machineHeight = 220
width = 600
eventWidth = 30
topOffset = 20
paddingLeft = 150
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
      circle = Visualizer.circle(eventX, timelineStartY, 10)
      circle.attr("fill", "#EEE")
      circle.attr("stroke", "#333")
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
