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
  
  machine = {name: name, gossip: gossip, receiveGossip: receiveGossip, events: events}
  knownMachines.push(machine)
  events.push({node: machine, hash: Math.random()})
  return machine


height = 300
draw = ->
  do Visualizer.clear
  timelineX = 0
  
  for machine, machineIndex in Visualizer.machines
    timelineX += 20
    startHeight = height - 20
    Visualizer.path("M #{timelineX},#{startHeight} l 0,#{-startHeight}")
    for event, eventIndex in machine.events
      circle = Visualizer.circle(timelineX, startHeight, 10)
      circle.attr("fill", "#EEE")
      circle.attr("stroke", "#999")


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
  
  
  

$ ->
  Visualizer.__proto__ = Raphael(document.getElementById('hashgraph_visualizer'))
  $('button#add-node').click ->
    Visualizer.addMachine(makeMachine('hello'))
    draw()
  Visualizer.addMachine(makeMachine('hello'))
  draw()
