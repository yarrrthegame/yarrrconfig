local yarrrconfig = require "yarrrconfig"

local test_object = {}
function test_object:add_behavior( behavior ) end

_G.Object = {
  new = function() return test_object end }

_G.PhysicalBehavior = {
  new = function() return "physical_behavior" end }

_G.Inventory = {
  new = function() return "inventory" end }

_G.Collider = {
  new = function() return "collider" end }

_G.DamageCauser = {
  new = function() return "damagecauser" end }

_G.LootDropper = {
  new = function() return "lootdropper" end }

_G.DeleteWhenDestroyed = {
  new = function() return "deletewhendestroyed" end }

local shape = {
  add_tile = function() end }

_G.Shape = {
  new = function() return shape end }

_G.ShapeBehavior = {
  new = function() return "shapebehavior" end }

_G.ShapeGraphics = {
  new = function() return "shapegraphics" end }

_G.ship_layer = "ship layer"

describe( "ship creator", function()

  describe( "the created object", function()
    local object_new = spy.on( Object, "new" )
    local object_add_behavior = spy.on( test_object, "add_behavior" )
    local collider_new = spy.on( Collider, "new" )
    local extra_behaviors = { "first extra behavior", "second extra behavior" }
    local tiles = { "first tile", "second tile" }
    local shape_add_tile = spy.on( shape, "add_tile" )
    local shape_behavior_new = spy.on( ShapeBehavior, "new" )

    local an_object = yarrrconfig.create_ship( tiles, extra_behaviors )

    it( "is an object", function()
      assert.spy( object_new ).was.called( 1 )
      assert.are.equal( test_object, an_object )
    end)

    it( "adds listed extra behaviors to the object", function()
      for i, behavior in ipairs( extra_behaviors ) do
        assert.spy( object_add_behavior ).was_called_with( test_object, behavior )
      end
    end)

    it( "adds listed tiles to the shape", function()
      for i, tile in ipairs( tiles ) do
        assert.spy( shape_add_tile ).was_called_with( shape, tile )
      end
      assert.spy( shape_behavior_new ).was_called_with( shape )
    end)

    it( "has physical behavior", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "physical_behavior" )
    end)

    it( "has inventory", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "inventory" )
    end)

    it( "has collider", function()
      assert.spy( collider_new ).was_called_with( ship_layer )
      assert.spy( object_add_behavior ).was_called_with( test_object, "collider" )
    end)

    it( "has damage causer", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "damagecauser" )
    end)

    it( "has loot dropper", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "lootdropper" )
    end)

    it( "is deleted when destroyed", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "deletewhendestroyed" )
    end)

    it( "has shape behavior", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "shapebehavior" )
    end)

    it( "has shape shapegraphics", function()
      assert.spy( object_add_behavior ).was_called_with( test_object, "shapegraphics" )
    end)

  end)

end)

