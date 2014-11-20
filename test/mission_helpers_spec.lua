local yarrrconfig = require "yarrrconfig"

local expected_object = { "sldkfj" }
local expected_object_id = "expected_object_id"
objects = {}
objects.expected_object_id = expected_object
_G.objects = objects

local existing_mission_id = "existing_mission_id"
missions = {}
missions.existing_mission_id = {}
missions.existing_mission_id.character = {}
missions.existing_mission_id.character.object_id = expected_object_id
_G.missions = missions

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

  describe( "ship of mission", function()

    it( "returns the ship object of the given mission", function()
      ship = yarrrconfig.ship_of_mission( existing_mission_id )
      assert.are.same( ship, expected_object )
    end)

  end)

end)

