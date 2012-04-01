Rect = {}

function Rect.isPointInside(rect, point, rectPosition)
    local x = point[1]
    local y = point[2]
    
    if rectPosition then
        x = x - rectPosition[1]
        y = y - rectPosition[2]
    end
    
    if x < rect[1] then return false end
    if y < rect[2] then return false end
    if x > rect[3] then return false end
    if y > rect[4] then return false end
    
    return true
end

return Rect