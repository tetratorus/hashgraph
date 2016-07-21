Visualizer = {
  machines: []
}
Visualizer.addMachine = (node) ->
  Visualizer.machines.push(node)
  

makeMachine = (name) ->
  knownMachines = []
  events = []
  
  gossip = ->
    console.log(node.name, ' is gossipping to ')
  receiveGossip = ->
    console.log(node.name, ' received gossip ')
  
  machine = {name: name, gossip: gossip, receiveGossip: receiveGossip, events: events, knownMachines: knownMachines}
  knownMachines.push(machine)
  events.push({node: machine, hash: Math.random()})
  return machine


height = 300
eventWidth = 30
topOffset = 20
draw = ->
  do Visualizer.clear
  timelineX = eventWidth
  
  for machine, machineIndex in Visualizer.machines
    machineWidth = machine.knownMachines.length * eventWidth + eventWidth
    rect = Visualizer.rect(timelineX - eventWidth, topOffset, machineWidth, height)
    rect.attr(stroke: '#ccc', fill: '#fafafa')
    text = Visualizer.text(timelineX + machineWidth/2 - eventWidth, 8, machine.name)
    startHeight = height - 30
    for node, index in machine.knownMachines
      path = Visualizer.path("M #{timelineX + index * eventWidth},#{startHeight} l 0,#{-startHeight+topOffset}")
      path.attr stroke: '#333'
      text = Visualizer.text(timelineX + index * eventWidth, height-10, node.name)
    for event, eventIndex in machine.events
      eventX = timelineX + machine.knownMachines.indexOf(event.node) * eventWidth
      circle = Visualizer.circle(eventX, startHeight, 10)
      circle.attr("fill", "#EEE")
      circle.attr("stroke", "#333")
    timelineX += machineWidth + 15 # padding


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
  $('button#add-node').click ->
    newMachine = makeMachine(names[Visualizer.machines.length])
    Visualizer.addMachine(newMachine)
    Visualizer.machines[0].knownMachines.push(newMachine)
    draw()
  $('button#add-node').click()
