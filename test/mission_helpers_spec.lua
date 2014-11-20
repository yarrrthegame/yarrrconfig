local yarrrconfig = require "yarrrconfig"

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

end)

