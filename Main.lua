Splash = require('Scripts.Splash')
Game = require('Scripts.Game')

function mainThread(viewport)
    local splash = Splash:new()
    local game = Game:new()
    splash:run(viewport)
    game:run(viewport)
end

function setupGame()

    -- Create the window
    MOAISim.openWindow("Promiscuous Pigeon", 1024, 768)

    -- Create the main viewport
    local viewport = MOAIViewport.new()

    -- Run the splash
    local thread = MOAIThread.new()
    thread:run(mainThread, viewport)
    
end

setupGame()
