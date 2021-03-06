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
      CargoSpace.new(),
      Collider.new( ship_layer ),
      ShapeBehavior.new( create_shape_from( tiles ) ),
      LootDropper.new(),
      DamageCauser.new(),
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

function yarrrconfig.random_velocity( max )
  return yarrrconfig.random_location_around( { x=0, y=0 }, max )
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

function yarrrconfig.ship_of_mission_by_id( mission_id )
  local mission = mission_contexts[ mission_id ]
  if mission == nil then
    return nil
  end

  return objects[ mission.character.object_id ]
end

function yarrrconfig.checkpoint( mission, destination, radius, till )
  if till < universe_time() then
    return failed
  end

  local ship = yarrrconfig.ship_of( mission )
  local distance_from_checkpoint = yarrrconfig.distance_between( ship.coordinate, destination )

  if distance_from_checkpoint <= radius then
    return succeeded
  end

  return ongoing
end

function yarrrconfig.coordinate_difference( a, b )
  return { x=a.x - b.x, y=a.y - b.y }
end

function yarrrconfig.coordinate_sum( a, b )
  return { x=a.x + b.x, y=a.y + b.y }
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
    function() return na end ) )
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

function yarrrconfig.wander_around( object, mission_id )
  object:set_velocity( yarrrconfig.coordinate_from( yarrrconfig.random_velocity( 50 ) ) )
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

function yarrrconfig.stay_in_position_for( message, mission, coordinate, seconds, done )
  local till = universe_time() + seconds

  yarrrconfig.add_objective_to( mission, {
    description = message,
    updater = function( mission )
      local ship = yarrrconfig.ship_of( mission )
      local diff = yarrrconfig.coordinate_difference( ship.coordinate, coordinate )
      if yarrrconfig.length_of( diff ) > 2000 then
        return failed
      end

      if universe_time() > till then
        return succeeded
      end

      return ongoing
    end,
    teardown = done
  } )
end

function yarrrconfig.go_to_in_seconds( mission, coordinate, seconds, on_arrive )
  local till = universe_time() + seconds

  yarrrconfig.add_objective_to( mission, {
    description = "Go to position " .. coordinate.x .. ", " .. coordinate.y .. " until " .. os.date( "!%T", till ) .. ".",
    updater = function( mission )
      return yarrrconfig.checkpoint( mission, coordinate, 500, till )
    end,
    teardown = on_arrive
  } )

end

function yarrrconfig.go_to( mission, coordinate, on_arrive )
  yarrrconfig.go_to_in_seconds( mission, coordinate, 300, on_arrive )
end

function yarrrconfig.go_home( mission )
  yarrrconfig.go_to( mission, { x=0, y=0 }, function() end )
end

function yarrrconfig.run( mission, speed, done )
  yarrrconfig.add_objective_to( mission, {
    description = "As fast as you can...",
    updater = function( mission )
      local ship = yarrrconfig.ship_of( mission )
      if yarrrconfig.length_of( ship.velocity ) > speed then
        return succeeded
      end
      return ongoing
    end,
    teardown = done
  } )
end

function does_mission_exist( id )
  return mission_contexts[ id ] ~= nil
end

function yarrrconfig.bind_to_mission( object, mission_id )
  local once_per_second = 1000000
  local behavior = LuaAgent.new( LuaFunction.new(
    function( object )
      if does_mission_exist( mission_id ) then
        return
      end

      object:destroy_self()
    end ),
    once_per_second )
  object:add_behavior( behavior )
end

return yarrrconfig

