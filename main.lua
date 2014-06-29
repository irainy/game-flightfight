local function Hero(  )
  local self = CCSprite:createWithSpriteFrameName("hero1.png")

  -- self:setAnchorPoint(CCPoint(self:getContentSize().width / 2, self:getContentSize().height / 2))
  return self
end
local function backgroundMove( sh, b1, b2 )
	local h = b2:boundingBox().size.height
	if b1:getPositionY() <= -1 * h then
		b1:setPositionY(b2:getPositionY() + h - 10)
	else
		b1:setPositionY(b1:getPositionY() - 10)
	end

	if b2:getPositionY() <= -1 * h then
		b2:setPositionY(b1:getPositionY() + h - 10)
	else
		b2:setPositionY(b2:getPositionY() - 10)
	end
end

local function GameScene (  )
  self = CCScene:create()
  local director = CCDirector:sharedDirector()

  local layer = CCLayer:create()
  layer:setPosition(CCPoint(0, 0))

  local gameBGOne = CCSprite:create("backaground.png")
  local gameBGTwo = CCSprite:create("backaground.png")

  gameBGOne:setAnchorPoint(CCPoint(0, 0))
  gameBGOne:setPosition(CCPoint(0, 0))

  scaleRate = director:getWinSize().width / gameBGOne:boundingBox().size.width
  gameBGOne:setScale(scaleRate)
  gameBGTwo:setScale(scaleRate)

  gameBGTwo:setAnchorPoint(CCPoint(0, 0))
  gameBGTwo:setPosition(CCPoint(0, gameBGTwo:boundingBox().size.height))


  layer:addChild(gameBGOne)
  layer:addChild(gameBGTwo)

  layer:scheduleUpdateWithPriorityLua(function()
  	backgroundMove(director:getWinSize().height, gameBGOne, gameBGTwo)
  end, 1)

  local hero  = Hero()

  hero:setPosition(CCPoint(director:getWinSize().width / 2, hero:getContentSize().height / 2))
  layer:addChild(hero)









  self:addChild(layer)
  -- key binding
  -- self:setKeypadEnabled(true)
  return self
end

local function main ()

  local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
  cache:addSpriteFramesWithFile("my_shoot.plist", "my_shoot.png")
  -- CCSpriteFrameCache:addSpriteFramesWithFile("ui/my_shoot.plist")
	local director = CCDirector:sharedDirector()
  local gameScene = GameScene()







	director:setDisplayStats(false)
	director:runWithScene(gameScene)
end

main()