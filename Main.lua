Splash = require('Scripts.Splash')
Game = require('Scripts.Game')

function mainThread(viewport)
    while true do
        local splash = Splash:new()
        local game = Game:new()
        splash:run(viewport)
        game:run(viewport)
    end
end

function setupGame()

    MOAIUntzSystem.initialize()

    -- Create the window
    MOAISim.openWindow("Coo.", 1024, 768)

    -- Create the main viewport
    local viewport = MOAIViewport.new()

    -- Run the splash
    local thread = MOAIThread.new()
    thread:run(mainThread, viewport)
    
end

setupGame()
