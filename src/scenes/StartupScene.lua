require 'Cocos2d'
require 'src/global'
require 'src/widgets/BackgroundRepeater'
require 'src/widgets/SimpleMenuItemSprite'
require 'src/widgets/Sky'
require 'src/scenes/Gameplay'
require 'src/scenes/AboutScene'
require 'src/scenes/GameOverScene'

StartupScene = {}
StartupScene.backToStartDur = 1.2
StartupScene.ballFadeOutDur = 0.5
StartupScene.parallaxBGRate = { [1] = 0.6, [2] = 0.35 }
StartupScene.parallaxBGScale = { [1] = 1.4, [2] = 2 }
StartupScene.parallaxBGDelta = { [1] = -35, [2] = 0 }
StartupScene.BGExtraWidth = 2400    -- it's enough, I think?
StartupScene.groundYOffset = 90
StartupScene.groundColour = cc.c3b(203, 126, 35)
StartupScene.parallaxYOffset = 75
StartupScene.titleYPadding = 24
StartupScene.titleFadeDur = 0.9
StartupScene.iconMenuPadding = 10
StartupScene.iconMenuGetInDur = 1.5
StartupScene.iconMenuGetOutDur = 0.6
StartupScene.iconMenuActionIntv = 0.2

function StartupScene.create()
    local scene = cc.Scene:create()
    local size = cc.Director:getInstance():getVisibleSize()
    -- prevent starting two games when tapping TOO fast on the phone
    local gameStarted = false
    
    local sky = Sky:create()
    scene:addChild(sky, -1)
    
    local titleSprite = globalSprite('game_title')
    titleSprite:setAnchorPoint(cc.p(0.5, 1))
    titleSprite:setPosition(cc.p(size.width / 2, size.height))
    titleSprite:setOpacity(0)
    scene:addChild(titleSprite)
    local scroll = MScrollView:create()
    scroll:horizonalMode()
    scroll:setContentSize(cc.size(AMPERE.MAPSIZE, size.height))
    scroll:setPositionX(-AMPERE.MAPSIZE / 2 + size.width / 2)
    scene:addChild(scroll, 0, Gameplay.scrollTag)
    -- create ground
    local ground_bg = BackgroundRepeater:create(AMPERE.MAPSIZE + StartupScene.BGExtraWidth * 2, 'ground', cc.p(0, 1))
    ground_bg:setPosition(cc.p(-StartupScene.BGExtraWidth, StartupScene.groundYOffset))
    local groundHeight = globalImageHeight('ground')
    local ugroundHeight = globalImageHeight('underground')
    local uground_bg_container = cc.Layer:create()
    local uground_totHeight = StartupScene.groundYOffset +
        StartupScene.groundYOffset * AMPERE.MAPSIZE / size.width
    local ugoundDepth = math.floor(uground_totHeight / ugroundHeight) + 2
    local maxWidth = AMPERE.MAPSIZE + StartupScene.BGExtraWidth * 2
    -- the background of the earth
    local earthPur = puritySprite(maxWidth, uground_totHeight, StartupScene.groundColour)
    earthPur:setAnchorPoint(cc.p(0, 1))
    earthPur:setPosition(cc.p(-StartupScene.BGExtraWidth, StartupScene.groundYOffset - groundHeight))
    uground_bg_container:addChild(earthPur, -1)
    -- the 'icing on the earth'
    for i = 1, ugoundDepth do
        local uground_bg = BackgroundRepeater:create(maxWidth, 'underground', cc.p(0, 1))
        uground_bg:setPosition(cc.p(-StartupScene.BGExtraWidth, (2-i) * ugroundHeight - groundHeight))
        uground_bg_container:addChild(uground_bg, i)
    end
    -- parallax nodes
    local parallax_bg = cc.ParallaxNode:create()
    parallax_bg:setPosition(cc.p(-StartupScene.BGExtraWidth, StartupScene.parallaxYOffset))
    for i = 1, #StartupScene.parallaxBGRate do
        parallax_bg:addChild(BackgroundRepeater:create(
            AMPERE.MAPSIZE + StartupScene.BGExtraWidth * 2,
            'parallax_bg_' .. i, cc.p(0, 0),
            StartupScene.parallaxBGDelta[i], StartupScene.parallaxBGScale[i]),
            i, cc.p(StartupScene.parallaxBGRate[i], 1), cc.p(0, 0))
    end
    scroll:addChild(parallax_bg, 18)
    scroll:addChild(uground_bg_container, 19)
    scroll:addChild(ground_bg, 20)
    
    -- create the crystal ball
    local crystalBallActive = globalSprite('crystal_ball_active')
    local crystalBallIdle = globalSprite('crystal_ball_idle')
    crystalBallActive:setAnchorPoint(cc.p(0.5, 0))
    crystalBallActive:setPosition(cc.p(AMPERE.MAPSIZE / 2, StartupScene.groundYOffset))
    crystalBallIdle:setAnchorPoint(cc.p(0.5, 0))
    crystalBallIdle:setPosition(cc.p(AMPERE.MAPSIZE / 2, StartupScene.groundYOffset))
    crystalBallIdle:setOpacity(0)
    -- avtive covers idle, just fade active out to set the ball to idle status
    scroll:addChild(crystalBallIdle, 40)
    scroll:addChild(crystalBallActive, 40)
    
    -- create the menu
    local start_item, options_item, about_item
    
    local idleCrystalBall = function()
        crystalBallIdle:setOpacity(255)
        crystalBallActive:runAction(cc.FadeOut:create(StartupScene.ballFadeOutDur))
    end
    local showStart = function()
        start_item:setVisible(true)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(StartupScene.titleFadeDur, cc.p(0, -StartupScene.titleYPadding)),
            cc.FadeIn:create(StartupScene.titleFadeDur)))
        local menuAction = cc.EaseElasticOut:create(
            cc.MoveBy:create(StartupScene.iconMenuGetInDur,
            cc.p(0, options_item:getContentSize().height)), 0.8)
        options_item:runAction(menuAction)
        about_item:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.iconMenuActionIntv),
            menuAction:clone()))
    end
    local hideStart = function()
        start_item:setVisible(false)
        titleSprite:runAction(cc.Spawn:create(
            cc.MoveBy:create(StartupScene.titleFadeDur, cc.p(0, StartupScene.titleYPadding)),
            cc.FadeOut:create(StartupScene.titleFadeDur)))
        local menuAction = cc.EaseElasticIn:create(
            cc.MoveBy:create(StartupScene.iconMenuGetOutDur,
            cc.p(0, -options_item:getContentSize().height)), 0.8)
        options_item:runAction(menuAction)
        about_item:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.iconMenuActionIntv),
            menuAction:clone()))
    end
    local activateCrystalBall = function()
        crystalBallActive:runAction(cc.FadeIn:create(StartupScene.ballFadeOutDur))
        start_item:setVisible(false)
        crystalBallIdle:runAction(cc.Sequence:create(
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.FadeOut:create(0)))
    end
    local backCallback = function(score, energy, balloon)
        gameStarted = false
        scroll:stopRefreshing()
        scroll:disableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.Spawn:create(
                cc.MoveTo:create(StartupScene.backToStartDur,
                  cc.p(-AMPERE.MAPSIZE / 2 + size.width / 2, 0)),
                cc.ScaleTo:create(StartupScene.backToStartDur, 1))),
            cc.CallFunc:create(idleCrystalBall),
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.CallFunc:create(showStart),
            cc.CallFunc:create(function()
                cc.Director:getInstance():pushScene(
                  GameOverScene:create(score, energy, balloon))
            end)))
    end
    local startCallback = function()
        if gameStarted then return end
        gameStarted = true
        scroll:enableTouching()
        scroll:runAction(cc.Sequence:create(
            cc.CallFunc:create(activateCrystalBall),
            cc.DelayTime:create(StartupScene.ballFadeOutDur),
            cc.CallFunc:create(hideStart)))
        Gameplay:boot(scene, backCallback)
    end
    start_item = SimpleMenuItemSprite:create('crystal_ball_idle', startCallback)
    start_item:setAnchorPoint(cc.p(0.5, 0))
    start_item:setPosition(cc.p(size.width / 2, StartupScene.groundYOffset))
    start_item:setVisible(false)
    local start_menu = cc.Menu:create(start_item)
    start_menu:setPosition(cc.p(0, 0))
    scene:addChild(start_menu, 33)
    options_item = SimpleMenuItemSprite:create('options', function() end)
    options_item:setAnchorPoint(cc.p(0, 0))
    options_item:setPosition(cc.p(0, -options_item:getContentSize().height))
    about_item = SimpleMenuItemSprite:create('about', function()
        cc.Director:getInstance():pushScene(AboutScene:create()) end)
    about_item:setAnchorPoint(cc.p(0, 0))
    about_item:setPosition(cc.p(globalImageWidth('options') + StartupScene.iconMenuPadding, -about_item:getContentSize().height))
    local icon_menu = cc.Menu:create(options_item, about_item)
    icon_menu:setPosition(cc.p(0, 0))
    scene:addChild(icon_menu, 33)
    
    crystalBallActive:setOpacity(0)
    crystalBallIdle:setOpacity(255)
    showStart()
    -- Let's go Lisp :)
    scroll:runAction(cc.Sequence:create(
        cc.DelayTime:create(0),     -- wait for one frame
        cc.CallFunc:create(function() scroll:disableTouching() end)))
    
    return scene
end
