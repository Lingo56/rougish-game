_G.love = require('lib-infinityShim')()

local Testee = require('main')

describe('tests from testing the testifications of the testificates tests', function()
  it('literally does nothing. literally.', function()
    -- Literally nothing.
    print(Testee)
    assert.are.equal(1 + 1, 2)
  end)
end)
