local yarrrconfig = require "yarrrconfig"

describe( "metrics", function()

  describe( "degrees", function()

    it( "converts degrees to hiplons", function()
      assert.are.equal( yarrrconfig.degrees( 10 ), 40 )
    end)

  end)

end)

