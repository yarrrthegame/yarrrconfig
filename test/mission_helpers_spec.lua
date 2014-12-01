local yarrrconfig = require "yarrrconfig"

local radius = 100

local expected_object = {}
object_coordinate = { x = 100, y = 100 }
expected_object.coordinate = object_coordinate
object_velocity = { x = 10, y = 10 }
expected_object.velocity = object_velocity
local expected_object_id = "expected_object_id"
objects = {}
objects.expected_object_id = expected_object
_G.objects = objects



local existing_mission_id = "existing_mission_id"
mission_contexts = {}
mission_contexts.existing_mission_id = {}
mission_contexts.existing_mission_id.character = {}
mission_contexts.existing_mission_id.character.object_id = expected_object_id
_G.mission_contexts = mission_contexts

local expected_context = mission_contexts.existing_mission_id

local existing_mission = { id = function( this ) return existing_mission_id end }

_G.failed = 0
_G.succeeded = 1
_G.ongoing = 2

function _G.universe_time()
  return 100000
end

describe( "mission helpers", function()

  describe( "distance between", function()

    it( "returns the distance between two coordinates ", function()
      a = { x = 10, y = 10 }
      b = { x = 20, y = 20 }
      assert.are.equal(
        math.sqrt( 200 ),
        yarrrconfig.distance_between( a, b ) )
    end)

  end)

  describe( "length of", function()

    it( "returns the length of the vector", function()
      a = { x = 5, y = 10 }
      assert.are.equal(
        math.sqrt( 125 ),
        yarrrconfig.length_of( a ) )
    end)

  end)

  describe( "is slower than", function()

    it( "returns true if the speed of the object is less than the given value", function()
      assert.is_true( yarrrconfig.is_slower_than( 14.15, expected_object ) )
    end)

    it( "returns false if the speed of the object is more than the given value", function()
      assert.is_false( yarrrconfig.is_slower_than( 14.14, expected_object ) )
    end)

  end)

  describe( "context of mission", function()

    it( "returns the context table for a given mission", function()
      local context = yarrrconfig.context_of( existing_mission )
      assert.are.same( context, expected_context )
    end)

  end)

  describe( "ship of mission", function()

    it( "returns the ship object of the given mission", function()
      local ship = yarrrconfig.ship_of( existing_mission )
      assert.are.same( ship, expected_object )
    end)

  end)

  describe( "checkpoint", function()

    function future()
      return universe_time() + 100
    end

    function past()
      return universe_time() - 100
    end

    function far_away()
      local coordinate = {
        x = object_coordinate.x + radius + 10,
        y = object_coordinate.y }
      return coordinate
    end

    function close_enough()
      local coordinate = {
        x = object_coordinate.x + radius,
        y = object_coordinate.y }
      return coordinate
    end

    it( "fails if timer expires", function()
      assert.are.equal(
        failed,
        yarrrconfig.checkpoint( existing_mission, far_away(), radius, past() ) )
    end)

    it( "returns ongoing if the object is far from the destination ", function()
      assert.are.equal(
        ongoing,
        yarrrconfig.checkpoint( existing_mission, far_away(), radius, future() ) )
    end)

    it( "returns succeeded if the object is closer than the radius to the destination ", function()
      assert.are.equal(
        succeeded,
        yarrrconfig.checkpoint( existing_mission, close_enough(), radius, future() ) )
    end)

  end)

  describe( "add objective to mission", function()
    function create_checker()
      local checker = {}
      checker.call_count = 0
      checker.call = function( this, parameter )
        this.was_called_with = parameter
        this.call_count = this.call_count + 1
      end
      return checker
    end

    local created_updater = nil
    local test_mission_id = "1"
    local test_mission = {
      id = function( this )
        return test_mission_id
      end,
      add_objective = function( this, objective )
        this.new_objective = objective
      end }

    local test_objective = {}
    local was_objective_created = false
    _G.MissionObjective = {
      new = function( description, updater )
        was_objective_created = true
        test_objective.description = description
        test_objective.updater = updater
        return test_objective
      end }

    local setup_checker = nil
    local updater_checker = nil
    local teardown_checker = nil
    local updater_status = nil
    local returned_status = nil
    local expected_description = "objective description appletree"

    function update_with_status( status )
      updater_status = status
      returned_status = created_updater( test_mission )
    end

    before_each( function()
      test_objective = {}
      test_mission.new_objective = {}
      was_objective_created = false
      updater_status = ongoing
      setup_checker = create_checker()
      updater_checker = create_checker()
      teardown_checker = create_checker()

      _G.mission_contexts = {}
      _G.mission_contexts[ test_mission_id ] = {}
      yarrrconfig.add_objective_to(
      test_mission,
      { description = expected_description,
        setup = function ( mission )
          setup_checker:call( mission )
        end,
        updater = function ( mission )
          updater_checker:call( mission )
          return updater_status
        end,
        teardown = function ( mission )
          teardown_checker:call( mission )
        end } )

      created_updater = test_objective.updater
      update_with_status( ongoing )
    end)


    it( "creates a mission objective", function()
      assert.is_true( was_objective_created )
    end)

    it( "creates the objective with the given description ", function()
      assert.are.equal( test_objective.description, expected_description )
    end)

    it( "adds the created objective to the mission", function()
      assert.are.equal( test_mission.new_objective, test_objective )
    end)

    it( "calls the set up function with the mission object", function()
      assert.are.equal( 1, setup_checker.call_count )
      assert.are.same( test_mission, setup_checker.was_called_with )
    end)

    it( "calls the set up function only the first time", function()
      created_updater( test_mission )
      assert.are.equal( 1, setup_checker.call_count )
    end)

    it( "calls the updater function with the mission object", function()
      assert.are.equal( 1, updater_checker.call_count )
      assert.are.same( test_mission, updater_checker.was_called_with )
    end)

    it( "calls the tear down function with the mission object if the updater succeeds", function()
      update_with_status( succeeded )
      assert.are.equal( 1, teardown_checker.call_count )
      assert.are.same( test_mission, teardown_checker.was_called_with )
    end)

    it( "calls the tear down function only if the updater succeeds", function()
      assert.are.equal( 0, teardown_checker.call_count )
      update_with_status( failed )
      assert.are.equal( 0, teardown_checker.call_count )
    end)

    function check_returns_correct_status( status )
      update_with_status( status )
      assert.are.equal( status, returned_status )
    end

    it( "returns with the return value of the updater", function()
      check_returns_correct_status( ongoing )
      check_returns_correct_status( succeeded )
      check_returns_correct_status( failed )
    end)

  end)

end)

