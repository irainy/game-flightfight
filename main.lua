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
    return pos.x  > 0 and
            pos.x  < CCDirector:sharedDirector():getWinSize().width and
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
    animation:setDelayPerUnit(0.1)
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
    local actionMove = CCMoveTo:create(math.random(3, 5), CCPoint(e:getPositionX(), -1*e:getContentSize().height))
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
  end, 0.5, false) 

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


  local score = 0
  local scoreItem = CCLabelBMFont:create("0", "markerFelt.fnt")
  -- scoreItem:setColor(ccColor3B(143, 146, 147))
  scoreItem:setAnchorPoint(CCPoint(0, 0.5))
  scoreItem:setPosition(CCPoint(scoreItem:getContentSize().width / 2 + 40, director:getWinSize().height - scoreItem:getContentSize().height / 2 - 40))
  heroLayer:addChild(scoreItem)

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


  local function updateScore(  )
    -- body
  end
  local function updateGame()
    for i,v in ipairs(enemyLayer.enemyArray) do
      for k,w in ipairs(bulletLayer.bulletArray) do
        if v:boundingBox():intersectsRect(w:boundingBox()) then
          enemyLayer:blowUP(v)
          bulletLayer:removeBullet(w)
          score = score + 100
          scoreItem:setString(score)
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
        animation:setDelayPerUnit(0.1)
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n1.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n2.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n3.png"))
        animation:addSpriteFrame(cache:spriteFrameByName("hero_blowup_n4.png"))
        local animate = CCAnimate:create(animation)

        local delay = CCDelayTime:create(1)

        local over = CCCallFunc:create(function (  )
          director:replaceScene(GameOverScene( score ))
        end)

        arr:addObject(animate)
        arr:addObject(delay)
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

function WelcomeScene(  )
  local director = CCDirector:sharedDirector()
  local layer = CCLayer:create()
  local self = CCScene:create()

  local bg = CCSprite:create("backaground.png")
  bg:setAnchorPoint(CCPoint(0, 0))
  bg:setPosition(CCPoint(0,0))

  local label = CCLabelTTF:create("START!", "Arial", 80);
  label:setPosition(CCPoint(director:getWinSize().width / 2, director:getWinSize().height / 2))

  -- local inputLabel = CCLabelTTF:create("Username", "Arial", 50)
 

  local highestScoreLabel = CCLabelTTF:create("Hello, " .. getUsername() .. "\n HighestScore : " .. getHighest(), "Arial", 40)
  highestScoreLabel:setPosition(CCPoint(label:getPositionX(), label:getPositionY() - label:getContentSize().height))

  scaleRate = director:getWinSize().width / bg:boundingBox().size.width
  bg:setScale(scaleRate)

  layer:addChild(bg)
  layer:addChild(label)
  layer:addChild(highestScoreLabel)

  local function startGame(e, x, y)
    if label:boundingBox():containsPoint(CCPoint(x, y)) then
      director:replaceScene(GameScene())
    end
  end
  self:addChild(layer)
  layer:setTouchEnabled(true)
  layer:registerScriptTouchHandler(startGame)
  return self
end

function GameOverScene( score )
  local director = CCDirector:sharedDirector()
  local self = CCScene:create()
  local overLayer = CCLayer:create()

  local bg = CCSprite:create("backaground.png")
  bg:setAnchorPoint(0,0)


  local label = CCLabelTTF:create("GAME OVER", "Arial", 80);
  label:setPosition(CCPoint(director:getWinSize().width / 2, director:getWinSize().height / 2))

  local scoreLabel = CCLabelTTF:create("Your Score: " .. score, "Arial", 40)
  scoreLabel:setPosition(CCPoint(label:getPositionX(), label:getPositionY() - label:getContentSize().height))

  local highestScore = getHighest()
  if score > highestScore then
    setHighest(score)
  end

  -- scaleRate = director:getWinSize().width / gameBGOne:boundingBox().size.width
  bg:setScale(scaleRate)
  overLayer:setPosition(CCPoint(0, 0))

  function restart(e, x, y)
    if label:boundingBox():containsPoint(CCPoint(x, y)) then
      director:replaceScene(GameScene())
    end
  end
  overLayer:addChild(bg)
  overLayer:addChild(label)
  overLayer:addChild(scoreLabel)
  self:addChild(overLayer)
  overLayer:setTouchEnabled(true)
  overLayer:registerScriptTouchHandler(restart)

  return self
end
local function LoginScene(  )
  local director = CCDirector:sharedDirector()
  local self = CCScene:create()
  local layer = CCLayer:create()

  local eb = CCEditBox:create(CCSize(300, 100), CCScale9Sprite:create())
  eb:setFontName("fonts/font.ttf")
  eb:setFontSize(45)
  eb:setPlaceHolder("Name:")
  eb:setMaxLength(8)
  eb:registerScriptEditBoxHandler(function ( e, sender )
    if e == "return" then
      print(sender:getText())
      setUsername(sender:getText())
      director:replaceScene(WelcomeScene())
    end
  end)
  eb:setPosition(CCPoint(director:getWinSize().width / 2, director:getWinSize().height / 2))


  layer:addChild(eb)
  self:addChild(layer)
  return self
end
local function main ()
  function clearFile(  )
      CCUserDefault:sharedUserDefault():setBoolForKey("hasFile", false)
      CCUserDefault:sharedUserDefault():flush()
  end

  function hasFile(  )
    if not CCUserDefault:sharedUserDefault():getBoolForKey("hasFile") then
      CCUserDefault:sharedUserDefault():setBoolForKey("hasFile", true)
      CCUserDefault:sharedUserDefault():setIntegerForKey("HighestScore", 0)
      CCUserDefault:sharedUserDefault():setStringForKey("Username", nil)
      CCUserDefault:sharedUserDefault():flush()
      return false
    else
      return true
    end
  end

  function getUsername(  )
    if hasFile() then
      return CCUserDefault:sharedUserDefault():getStringForKey("Username")
    else
      return nil
    end
  end
  function setUsername( name )
    CCUserDefault:sharedUserDefault():setStringForKey("Username", name)
    CCUserDefault:sharedUserDefault():flush()
  end
  function getHighest(  )
    if hasFile() then
      return CCUserDefault:sharedUserDefault():getIntegerForKey("HighestScore")
    else
      return 0
    end
  end
  function setHighest( score )
    CCUserDefault:sharedUserDefault():setIntegerForKey("HighestScore", score)
    CCUserDefault:sharedUserDefault():flush()
  end

  schedulerStack = {}

  local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
  cache:addSpriteFramesWithFile("my_shoot.plist", "my_shoot.png")
  -- CCSpriteFrameCache:addSpriteFramesWithFile("ui/my_shoot.plist")
	local director = CCDirector:sharedDirector()
  -- local gameScene = GameScene()
  clearFile()
  director:setDisplayStats(false)
  if not getUsername() then
    director:runWithScene(LoginScene())
  else
    director:runWithScene(WelcomeScene())
  end
end

main()