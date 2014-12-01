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


function yarrrconfig.random_location_around( center, range )
  local location = {
    x = center.x + math.random( -range, range ),
    y = center.y + math.random( -range, range ) }

  return location
end


function yarrrconfig.coordinate_from( location )
  return Coordinate.new( metres( location.x ), metres( location.y ) )
end


function yarrrconfig.distance_between( a, b )
  return math.sqrt( math.pow( a.x - b.x, 2 ) + math.pow( a.y - b.y, 2 ) )
end

function yarrrconfig.context_of( mission )
  return mission_contexts[ mission:id() ]
end

function yarrrconfig.ship_of( mission )
  return objects[ yarrrconfig.context_of( mission ).character.object_id ]
end

function yarrrconfig.checkpoint( mission, destination, radius, till )
  if till < universe_time() then
    return failed
  end

  local ship = yarrrconfig.ship_of( mission )
  local distance_from_checkpoin = yarrrconfig.distance_between( ship.coordinate, destination )

  if distance_from_checkpoin <= radius then
    return succeeded
  end

  return ongoing
end


function yarrrconfig.length_of( vector )
  return yarrrconfig.distance_between( { x=0, y=0 }, vector )
end

function yarrrconfig.is_slower_than( speed, object )
  return yarrrconfig.length_of( object.velocity ) < speed
end


function yarrrconfig.add_instruction( mission, message )
  mission:add_objective( MissionObjective.new(
    message,
    function() return succeeded end ) )
end

function wrap_updater( setup, updater, teardown )
  return function( mission )
    local context = yarrrconfig.context_of( mission )
    if context.was_setup_called == nil then
      context.was_setup_called = true
      setup( mission )
    end
    status = updater( mission )

    if status == succeeded then
      context.was_setup_called = nil
      teardown( mission )
    end

    return status
  end
end

function fix_function_if_nil( objective_data, name )
  if objective_data[ name ] == nil then
    objective_data[ name ] = function() end
  end
end

function fix_objective_data( objective_data )
  fix_function_if_nil( objective_data, "setup" )
  fix_function_if_nil( objective_data, "updater" )
  fix_function_if_nil( objective_data, "teardown" )

  if objective_data.description == nil then
    objective_data.description = "WARNING: missing description"
  end
end

function yarrrconfig.add_objective_to( mission, objective_data )
  fix_objective_data( objective_data )
  local objective = MissionObjective.new(
    objective_data.description,
    wrap_updater(
      objective_data.setup,
      objective_data.updater,
      objective_data.teardown ) )
  mission:add_objective( objective )
end

return yarrrconfig

