local yarrrconfig = {}

function create_shape_from( tiles )
  local local_shape = Shape.new()
  for i, tile  in ipairs( tiles ) do
    local_shape:add_tile( tile )
  end

  return local_shape
end

function add_behaviors_to( object, behaviors )
  for i, behavior  in ipairs( behaviors ) do
    object:add_behavior( behavior )
  end
end

function yarrrconfig.create_ship( object, tiles, additional_behaviors )
  add_behaviors_to( object, {
      PhysicalBehavior.new(),
      Inventory.new(),
      Collider.new( ship_layer ),
      DamageCauser.new( 100 ),
      LootDropper.new(),
      ShapeBehavior.new( create_shape_from( tiles ) ),
      ShapeGraphics.new()
    } )

  add_behaviors_to( object, additional_behaviors )
end

function yarrrconfig.distance_between( a, b )
  return math.sqrt( math.pow( a.x - b.x, 2 ) + math.pow( a.y - b.y, 2 ) )
end


function yarrrconfig.ship_of_mission( mission_id )
  return objects[ missions[ mission_id ].character.object_id ]
end

return yarrrconfig

