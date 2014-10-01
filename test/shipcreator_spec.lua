local yarrrconfig = require "yarrrconfig"

local test_object = {}
_G.Object = { new = function() return test_object end }

describe( "ship creator", function()

  it( "creates objects", function()
    local s = spy.on( Object, "new" )
    local an_object = yarrrconfig.create_ship()
    assert.spy( s ).was.called( 1 )
    assert.are.equal( test_object, an_object )
  end)

end)

