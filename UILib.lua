--- Makes any Frame draggable by its handle (header).
---@param window    Frame
---@param handle    GuiObject
---@param dragSpeed number|nil   (legacy, ignored)
---@param isMobile  boolean|nil  (legacy, ignored)
function UILib.makeDraggable(window, handle, dragSpeed, isMobile)
    if not window or not handle then return end

    local dragging = false
    local startPos = nil
    local startMouse = nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 
           and inp.UserInputType ~= Enum.UserInputType.Touch then 
            return 
        end

        -- Safety bounds check
        local ap = handle.AbsolutePosition
        local as = handle.AbsoluteSize
        local pos = inp.Position

        if not pos or pos.X < ap.X or pos.X > ap.X + as.X 
        or pos.Y < ap.Y or pos.Y > ap.Y + as.Y then
            return
        end

        dragging = true
        startPos = window.Position
        startMouse = Vector2.new(pos.X, pos.Y)
    end)

    _UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if not inp.Position then return end

        if inp.UserInputType ~= Enum.UserInputType.MouseMovement 
           and inp.UserInputType ~= Enum.UserInputType.Touch then 
            return 
        end

        local currentPos = inp.Position
        local delta = currentPos - startMouse

        window.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    _UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
