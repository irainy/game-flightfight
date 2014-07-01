local function Hero( )
  local self = CCSprite:createWithSpriteFrameName("hero1.png")
  self:setAnchorPoint(CCPoint(0.5, 0))
  local blink = CCBlink:create(1,3)
  local heroAni = CCAnimation:create()
  local cache  = CCSpriteFrameCache:sharedSpriteFrameCache()
  heroAni:setDelayPerUnit(0.1)
  heroAni:addSpriteFrame(cache:spriteFrameByName("hero1.png"))
  heroAni:addSpriteFrame(cache:spriteFrameByName("hero2.png"))

  self.width = self:getContentSize().width
  self.height = self:getContentSize().height

  local animate = CCAnimate:create(heroAni)

  self:runAction(blink)
  self:runAction(CCRepeatForever:create(animate))

  function isInScreen( pos )
    return pos.x - self.width / 2 > 0 and
            pos.x + self.width / 2 < CCDirector:sharedDirector():getWinSize().width and
            pos.y > 0 and
            pos.y + self.height < CCDirector:sharedDirector():getWinSize().height
  end
  function self:moveTo( offset )
    local to = CCPoint(self:getPositionX() + offset.x, self:getPositionY() + offset.y)
    if isInScreen(to) then
      self:setPosition(to)
    end
  end
  return self
end
local function Enemy( type )
  local self = CCSprite:createWithSpriteFrameName("enemy1.png")
  self:setPosition(CCPoint(100, 100))

  return self
end

local function BulletLayer( hero )
  local self = CCLayer:create()
  local director = CCDirector:sharedDirector()
  local texture = CCTextureCache:sharedTextureCache():textureForKey("my_shoot.png")
  local bulletBatchNode = CCSpriteBatchNode:createWithTexture(texture)

  function bulletMoveFinished( bullet )
    if bullet:getPositionY() > director:getWinSize().height then
      bullet = nil
      bulletBatchNode:removeChild(bullet)
    end
  end
  function self:AddBullet( )
    local bullet = CCSprite:createWithSpriteFrameName("bullet1.png")
    bullet:setAnchorPoint(CCPoint(0.5, 0))
    bullet:setPosition(CCPoint(hero:getPositionX(), hero:getPositionY() + hero:getContentSize().height))

    -- bulletBatchNode:addChild(bullet)

    local length = director:getWinSize().height
    local velocity=420
    local realMoveDuration = length / velocity

    local arr = CCArray:create()
    local actionMove = CCMoveTo:create(realMoveDuration, CCPoint(hero:getPositionX(), length))
    local delay = CCDelayTime:create(0.8)
    local remove = CCCallFunc:create(function (  )
      bulletMoveFinished(bullet)
    end)
    arr:addObject(actionMove)
    arr:addObject(remove)
    arr:addObject(delay)

    local seq = CCSequence:create(arr)
    bulletBatchNode:addChild(bullet)
    bullet:runAction(seq)
  end
  function self:startShoot(  )
    local scheduler = director:getScheduler()
    scheduler:scheduleScriptFunc(function ()
      self:AddBullet()
    end, 0.3, false) 
    self:addChild(bulletBatchNode)
  end

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

local function EnemyLayer(  )
  local self = CCLayer:create()
  self:setPosition(CCPoint(0, 0))

  local en1 = Enemy(1)
  self:addChild(en1)

  return self
end

local function GameScene (  )
  self = CCScene:create()
  local director = CCDirector:sharedDirector()

  local bgLayer = CCLayer:create()
  bgLayer:setPosition(CCPoint(0, 0))

  local gameBGOne = CCSprite:create("backaground.png")
  local gameBGTwo = CCSprite:create("backaground.png")

  gameBGOne:setAnchorPoint(CCPoint(0, 0))
  gameBGOne:setPosition(CCPoint(0, 0))

  scaleRate = director:getWinSize().width / gameBGOne:boundingBox().size.width
  gameBGOne:setScale(scaleRate)
  gameBGTwo:setScale(scaleRate)

  gameBGTwo:setAnchorPoint(CCPoint(0, 0))
  gameBGTwo:setPosition(CCPoint(0, gameBGTwo:boundingBox().size.height))


  bgLayer:addChild(gameBGOne)
  bgLayer:addChild(gameBGTwo)

  bgLayer:scheduleUpdateWithPriorityLua(function()
  	backgroundMove(director:getWinSize().height, gameBGOne, gameBGTwo)
  end, 1)


  -- add hero
  local heroLayer = CCLayer:create()
  heroLayer:setPosition(CCPoint(0, 0))
  local hero  = Hero()
  hero:setPosition(CCPoint(director:getWinSize().width / 2, 0))

  -- print("Hero height: ", hero:getContentSize().height, " Hero getPositionY: ", hero:getPositionY())


  local touchBeginPoint = nil
  local function onTouchBegan( x, y )
    touchBeginPoint = {x=x, y=y}
    return true
  end
  local function onTouchMoved( x, y )
    local heroRect = hero:boundingBox()
    if heroRect:containsPoint(CCPoint(x, y)) then
      if touchBeginPoint then
        local offset = CCPoint(x - touchBeginPoint.x, y - touchBeginPoint.y)
        hero:moveTo(offset)
        touchBeginPoint = {x=x, y=y}
      end
    else
      print("Plane not touched")
    end
    return false
  end
  local function onTouchEnded( x, y )
    touchBeginPoint = nil
    return true
  end
  local function onTouch( eventType, x, y )
    print(eventType)
    if eventType == "began" then
      return onTouchBegan(x, y)
    elseif eventType == "moved" then
      return onTouchMoved(x, y)
    elseif eventType == "ended" then
      return onTouchEnded(x, y)
    end
  end 
  heroLayer:addChild(hero)
  heroLayer:setTouchEnabled(true)
  heroLayer:registerScriptTouchHandler(onTouch)

  -- add bullets
  local bulletLayer = BulletLayer( hero )
  bulletLayer:startShoot()


  -- enemy layer
  local enemyLayer = EnemyLayer()

  self:addChild(bgLayer)
  self:addChild(heroLayer)
  self:addChild(bulletLayer)
  self:addChild(enemyLayer)
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