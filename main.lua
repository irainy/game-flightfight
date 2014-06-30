local function Hero( )
  local self = CCSprite:createWithSpriteFrameName("hero1.png")
  self:setAnchorPoint(CCPoint(0.5, 0))
  -- self:setAnchorPoint(CCPoint(self:getContentSize().width / 2, self:getContentSize().height / 2))
  local blink = CCBlink:create(1,3)
  local heroAni = CCAnimation:create()
  local cache  = CCSpriteFrameCache:sharedSpriteFrameCache()
  heroAni:setDelayPerUnit(0.1)
  heroAni:addSpriteFrame(cache:spriteFrameByName("hero1.png"))
  heroAni:addSpriteFrame(cache:spriteFrameByName("hero2.png"))

  local animate = CCAnimate:create(heroAni)

  self:runAction(blink)
  self:runAction(CCRepeatForever:create(animate))
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


  -- add hero
  local hero  = Hero()
  hero:setPosition(CCPoint(director:getWinSize().width / 2, 0))

  print("Hero height: ", hero:getContentSize().height, " Hero getPositionY: ", hero:getPositionY())
  layer:addChild(hero)

  -- add bullets
  local bulletLayer = CCLayer:create()


  -- CCTextureCache:sharedTextureCache():addImage("my_shoot.png")
  local texture = CCTextureCache:sharedTextureCache():textureForKey("my_shoot.png")
  local bulletBatchNode = CCSpriteBatchNode:createWithTexture(texture)

  local function AddBullet()
    -- local bullet = CCSprite:createWithTexture(bulletBatchNode:getTexture())
    local bullet = CCSprite:createWithSpriteFrameName("bullet1.png")
    bullet:setAnchorPoint(CCPoint(0.5, 0))
    bullet:setPosition(CCPoint(hero:getPositionX(), hero:getContentSize().height))

    -- bulletBatchNode:addChild(bullet)

    local length = director:getWinSize().height
    local velocity=420
    local realMoveDuration = length / velocity

    local arr = CCArray:create()
    local actionMove = CCMoveTo:create(realMoveDuration, CCPoint(hero:getPositionX(), length))
    local delay = CCDelayTime:create(0.8)
    arr:addObject(actionMove)
    arr:addObject(delay)
    local seq = CCSequence:create(arr)

    bulletLayer:addChild(bullet)
    bullet:runAction(seq)
  end

  local scheduler = director:getScheduler()
  scheduler:scheduleScriptFunc(AddBullet, 0.5, false) 
  -- bulletLayer:scheduleUpdateWithPriorityLua(function()
  --   AddBullet()
  -- end,1)

  bulletLayer:addChild(bulletBatchNode)





  self:addChild(layer)
  self:addChild(bulletLayer)
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