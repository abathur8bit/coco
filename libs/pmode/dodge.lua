print("lua says... " .. emu.app_name() .. " " .. emu.app_version())
cpu = manager.machine.devices[':maincpu']
mem = cpu.spaces["program"]
screen = manager.machine.screens[':screen']
capturedFrameValue = 0
capturedFrameSum = 0
capturedFrameCount = 0

function draw_overlay()
    -- current frame progress
    draw_meter(10, 20, "current", capturedFrameValue)

    -- running average
    if capturedFrameCount ~= 0 then
        draw_meter(10, 140, "average", capturedFrameSum / capturedFrameCount)
    end
end

function draw_meter(xLeft, yUp, title, value)
    xRight = xLeft + 30
    yDn = yUp + 60
    framePercent = math.floor(value*1000+0.5)/10

    -- title
    screen:draw_text(xLeft+2, yUp - 12, title)

    -- bounding box
    screen:draw_box(xLeft, yUp, xRight, yDn, 0xff00ffff, 0xff000000)

    -- meter
    yMeterUp = yDn - (value*(yDn - yUp))
    screen:draw_box(xLeft, yMeterUp, xRight, yDn, 0xffffffff, 0xffffffff)

    -- level lines
    for y = yUp, yDn, (yDn - yUp)/8 do
        screen:draw_line(xLeft, y, xRight, y, 0xff00ffff)
    end

    -- text form of meter value
    screen:draw_text(
        xLeft,
        yDn + 5,
        framePercent .. "% frame\nremaining")
end


emu.register_frame_done(draw_overlay, 'frame')

function captureFrameProgress(offset, val, mask)
    seconds = screen:time_until_vblank_start():as_double()
    capturedFrameValue = seconds*60
    capturedFrameSum = capturedFrameSum + capturedFrameValue
    capturedFrameCount = capturedFrameCount + 1
end

handler = mem:install_write_tap(0x7800, 0x7800, "captureFrameProgress", captureFrameProgress)
manager.machine.natkeyboard:post("LOADM\"DODGE\":EXEC\n\"")