local yarrrconfig = {}

function create_shape_from( tiles )
  local local_shape = Shape.new()
  for i, tile  in ipairs( tiles ) do
    local_shape:add_tile( tile )
  end

  return local_shape
end

function add_behaviors_to( ship, behaviors )
  for i, behavior  in ipairs( behaviors ) do
    ship:add_behavior( behavior )
  end
end

function yarrrconfig.create_ship( tiles, additional_behaviors )
  ship = Object.new()
  add_behaviors_to( ship, {
      PhysicalBehavior.new(),
      Inventory.new(),
      Collider.new( ship_layer ),
      DamageCauser.new( 100 ),
      LootDropper.new(),
      DeleteWhenDestroyed.new(),
      ShapeBehavior.new( create_shape_from( tiles ) ),
      ShapeGraphics.new()
    } )

  add_behaviors_to( ship, additional_behaviors )
  return ship
end

return yarrrconfig

