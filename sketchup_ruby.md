


* source https://www.youtube.com/watch?v=_NBSN_87F9U


```
m = Sketchup.active_model
m.entities.count  # =>  0

f = m.entities.add_face [[0,0,0],[100,0,0],[100,100,0],[0,100,0]]

m.entities.count   #  => 5
m.entities.to_a

f.pushpull -100  # will pull up 100 and form a cube 

m.entities.each do |entity|
  if entity.is_a? Sketchup::Face
   entity.material = Sketchup::Color.new(100, 255, 255)
  end
end

f.edges.length  # face have 4 edges

edge = f.edges[0]
edge.start.position     #  <Geom::Print3d [0,0,0] 
edge.end.position       #  <Geom::Print3d [100,0,0]
edge.length             #  100.0


f.area


(1..100).each do |i|
  f = m.entities.add_face [[10 * i,10 * i,10 * i],[20 * i,10 * i,10 * i],[20 * i,20 * i,10 * i],[10 * i,20 * i,10 * i]]
  f.pushpull -100
end

```
