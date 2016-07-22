Visualizer = {
  machines: []
}
Visualizer.addMachine = (node) ->
  Visualizer.machines.push(node)
Visualizer.sendMessage = (fromMachine, toMachine, message, duration = 1000 + Math.random() * 2000) ->
  onArrive = ->
    console.log('woot')
    toMachine.receiveMessage(message)
    messageCircle.remove()
  toX = toMachine.position.left
  toY = toMachine.position.top
  fromX = fromMachine.position.left
  fromY = fromMachine.position.top
  messageCircle = Visualizer.circle(fromX, fromY, 15)
  messageCircle.animate {transform: ["T",toX-fromX,toY-fromY]}, duration
  delay duration, onArrive
  console.log(fromMachine.name, '->', toMachine.name)

makeMachine = (name) ->
  machine = {}
  knownMachines = []
  events = []
  
  gossip = ->
    return alert("Dont know any machines. Cant gossip") if knownMachines.length == 1
    receiver = knownMachines[Math.floor(Math.random()*knownMachines.length)] until receiver and receiver.name != name
    
    Visualizer.sendMessage(machine, receiver, 'hello')
  
  receiveMessage = ->
    console.log(name, ' received gossip ')
  
  Object.assign machine, 
    name: name,
    gossip: gossip,
    receiveMessage: receiveMessage,
    events: events,
    knownMachines: knownMachines
    
  events.push({node: machine, hash: Math.random()})
  return machine


height = 800
machineHeight = 220
width = 600
eventWidth = 30
topOffset = 20
paddingLeft = 150
draw = ->
  do Visualizer.clear
    
  for machine, machineIndex in Visualizer.machines
    machineAngle = machineIndex * 2 * Math.PI / Visualizer.machines.length  
    machineWidth = machine.knownMachines.length * eventWidth + eventWidth    
    machineX = (1+Math.cos(-machineAngle-Math.PI)) * width / 2 - eventWidth - machineWidth / 2 + paddingLeft
    machineY = (1+Math.sin(-machineAngle)) * (height-machineHeight) / 2
    machine.position = {left: machineX, top: machineY}
    machine.dimensions = {width: machineWidth, height: machineHeight}
    rect = Visualizer.rect(machineX, machineY+topOffset, machineWidth, machineHeight)
    rect.attr(stroke: '#ccc', fill: '#fafafa')
    text = Visualizer.text(machineX+machineWidth/2, machineY + 8, machine.name)
    timelineStartY = machineY + machineHeight - 20
    for node, index in machine.knownMachines
      path = Visualizer.path("M #{machineX + eventWidth + index * eventWidth},#{timelineStartY} l 0,#{-machineHeight+topOffset+20}")
      path.attr stroke: '#333'
      text = Visualizer.text(machineX + eventWidth + index * eventWidth, machineY+machineHeight, node.name)
    for event, eventIndex in machine.events
      eventX = machineX + eventWidth + machine.knownMachines.indexOf(event.node) * eventWidth
      circle = Visualizer.circle(eventX, timelineStartY, 10)
      circle.attr("fill", "#EEE")
      circle.attr("stroke", "#333")


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
      newMachine.knownMachines.push(machine)
    draw()
    $("<button>Make #{name} gossip</button>").appendTo($('#gossips')).click newMachine.gossip
  
  $('button#add_node').click()
  $('button#add_node').click()

delay = (t, fn) ->
  setTimeout fn, t
