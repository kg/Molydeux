Rect = {}

function Rect.isPointInside(rect, point)
    if point[1] < rect[1] then return false end
    if point[2] < rect[2] then return false end
    if point[1] > rect[3] then return false end
    if point[2] > rect[4] then return false end
    
    return true
end

return Rect