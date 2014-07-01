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
  local rep = self:runAction(CCRepeatForever:create(animate))
  rep:setTag(1)


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
  local director = CCDirector:sharedDirector()
  local self = CCSprite:createWithSpriteFrameName("enemy2.png")
 
  return self
end

local function BulletLayer( hero )
  local self = CCLayer:create()
  local director = CCDirector:sharedDirector()
  local texture = CCTextureCache:sharedTextureCache():textureForKey("my_shoot.png")
  local bulletBatchNode = CCSpriteBatchNode:createWithTexture(texture)

  self.bulletArray = {} --CCArray:create()
  -- self.bulletArray:retain()

  function self:removeBullet( bullet )
     bulletBatchNode:removeChild(bullet, true)
     self:removeChild(bullet, true)
      for i,v in ipairs(self.bulletArray) do
        if v == bullet then
          self.bulletArray[i] = self.bulletArray[#self.bulletArray]
          table.remove(self.bulletArray, #self.bulletArray)
          break
        end
      end
  end

  function bulletMoveFinished( bullet )
    if bullet:getPositionY() >= director:getWinSize().height then
      self:removeBullet(bullet)
    end
  end
  function self:AddBullet( )
    local bullet = CCSprite:createWithSpriteFrameName("bullet1.png")

    bullet:setAnchorPoint(CCPoint(0.5, 0))
    bullet:setPosition(CCPoint(hero:getPositionX(), hero:getPositionY() + hero:getContentSize().height))

    table.insert(self.bulletArray, bullet)

    local length = director:getWinSize().height
    local velocity=420
    local realMoveDuration = length / velocity

    local arr = CCArray:create()
    local actionMove = CCMoveTo:create(realMoveDuration, CCPoint(hero:getPositionX(), length))
    -- local delay = CCDelayTime:create(0.8)
    local remove = CCCallFunc:create(function (  )
      bulletMoveFinished(bullet)
    end)
    arr:addObject(actionMove)
    arr:addObject(remove)
    -- arr:addObject(delay)

    local seq = CCSequence:create(arr)
    bulletBatchNode:addChild(bullet)
    bullet:runAction(seq)
  end
  function self:startShoot(  )
    local scheduler = director:getScheduler()
    local handler = scheduler:scheduleScriptFunc(function ()
      self:AddBullet()
    end, 0.3, false) 
    table.insert(schedulerStack, handler)
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
  math.randomseed(os.time())
  local self = CCLayer:create()
  local director = CCDirector:sharedDirector()
  self:setPosition(CCPoint(0, 0))

  self.enemyArray = {}

  function self:blowUP( enemy )
    local arr =CCArray:create()

    -- local animation = CCAnimationCache:sharedAnimationCache():animationByName("Enemy2Blowup");
    local cache  = CCSpriteFrameCache:sharedSpriteFrameCache()

    local animation = CCAnimation:create()
    animation:setDelayPerUnit(0.05)
    animation:addSpriteFrame(cache:spriteFrameByName("enemy2_down1.png"))
    animation:addSpriteFrame(cache:spriteFrameByName("enemy2_down2.png"))
    animation:addSpriteFrame(cache:spriteFrameByName("enemy2_down3.png"))
    animation:addSpriteFrame(cache:spriteFrameByName("enemy2_down4.png"))
    animate = CCAnimate:create(animation)
    local remove = CCCallFunc:create(function (  )
      self:removeEnemy(enemy)
    end)

    arr:addObject(animate)
    arr:addObject(remove)
    local seq = CCSequence:create(arr)

    enemy:runAction(seq)
  end
  function enemyMoveFinished( enemy )
    if enemy:getPositionY() <= -1*enemy:getContentSize().height then
      self:removeEnemy(enemy)
    end
  end
  function self:removeEnemy( e )
    for i,v in ipairs(self.enemyArray) do
      if e == v then
        self.enemyArray[i] = self.enemyArray[#self.enemyArray]
        table.remove(self.enemyArray, #self.enemyArray)
        break
      end
    end
    self:removeChild(e, true)
  end
  function self:addEnemy()
    local e = Enemy(1)

    table.insert(self.enemyArray, e)
    local minX = e:getContentSize().width / 2
    local maxX = director:getWinSize().width - e:getContentSize().width / 2

    local randX = math.random(minX, maxX)
    e:setPosition(CCPoint(randX, director:getWinSize().height))
    local arr = CCArray:create()
    local actionMove = CCMoveTo:create(5, CCPoint(e:getPositionX(), -1*e:getContentSize().height))
    local remove = CCCallFunc:create(function (  )
      enemyMoveFinished(e)
    end)

    arr:addObject(actionMove)
    arr:addObject(remove)

    local seq = CCSequence:create(arr)
    e:runAction(seq)

    self:addChild(e)
  end
  local scheduler = CCDirector:sharedDirector():getScheduler()
  local handler = scheduler:scheduleScriptFunc(function ()
    self:addEnemy()
  end, 1, false) 

  table.insert(schedulerStack, handler)

  return self
end

local function GameScene (  )
  local self = CCScene:create()
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
      -- print("Plane not touched")
    end
    return false
  end
  local function onTouchEnded( x, y )
    touchBeginPoint = nil
    return true
  end
  local function onTouch( eventType, x, y )
    -- print(eventType)
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


  local function updateGame()
    for i,v in ipairs(enemyLayer.enemyArray) do
      for k,w in ipairs(bulletLayer.bulletArray) do
        if v:boundingBox():intersectsRect(w:boundingBox()) then
          enemyLayer:blowUP(v)
          bulletLayer:removeBullet(w)
        end
      end
      if v:boundingBox():intersectsRect(hero:boundingBox()) then
        for i,v in ipairs(schedulerStack) do
          director:getScheduler():unscheduleScriptEntry(v)
        end
        schedulerStack = {}

        hero:stopActionByTag(1)

        local arr = CCArray:create()

        local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
        local animation = CCAnimation:create()
        animation:setDelayPerUnit(0.05)
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n1.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n2.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n3.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n4.png"))
        local animate = CCAnimate:create(animation)

        local over = CCCallFunc:create(function (  )
          director:replaceScene(GameOverScene())
        end)

        arr:addObject(animate)
        arr:addObject(over)
        local seq = CCSequence:create(arr)
        hero:runAction(seq)
        -- director:replaceScene(GameOverScene())
        -- print("Game Over")
      end
    end
    -- print("bulletArray", #bulletLayer.bulletArray)
    -- print("enemyArray", #enemyLayer.enemyArray)
  end
  self:scheduleUpdateWithPriorityLua(updateGame, 1)
  -- key binding
  -- self:setKeypadEnabled(true)
  return self
end

function GameOverScene()
  local director = CCDirector:sharedDirector()
  local self = CCScene:create()
  local overLayer = CCLayer:create()

  local bg = CCSprite:create("backaground.png")
  bg:setAnchorPoint(0,0)


  local label = CCLabelTTF:create("GAME OVER", "Marker Felt", 80);
  label:setPosition(CCPoint(director:getWinSize().width / 2, director:getWinSize().height / 2))

  -- scaleRate = director:getWinSize().width / gameBGOne:boundingBox().size.width
  bg:setScale(scaleRate)
  overLayer:setPosition(CCPoint(0, 0))


  overLayer:addChild(bg)
  overLayer:addChild(label)
  self:addChild(overLayer)

  return self
end
local function main ()

  schedulerStack = {}

  local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
  cache:addSpriteFramesWithFile("my_shoot.plist", "my_shoot.png")
  -- CCSpriteFrameCache:addSpriteFramesWithFile("ui/my_shoot.plist")
	local director = CCDirector:sharedDirector()

  local gameScene = GameScene()
	director:setDisplayStats(false)
	director:runWithScene(gameScene)
end

main()