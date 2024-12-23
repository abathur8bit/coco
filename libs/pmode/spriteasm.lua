function say(s)
 print(s)
end

function fcbold(cel)
 local img = cel.image:clone()
 local sprite = cel.sprite
 for y=0,sprite.width do
  for x=0,sprite.height do
   print("  x,y"..x,y)
  end
 end
 
 local sw=cel.sprite.width
 local sh=cel.sprite.height
 for i=1,10 do print(i) end
 print("  image w="..img.width.." height="..img.height.." sw="..cel.sprite.width.." sh="..cel.sprite.height)
 
-- for it in img:pixels() do
--  local pixelValue = it() -- get pixel
--  
--  print("   x="..it.x.." y="..it.y.." pixel value="..pixelValue)       -- get pixel x,y coordinates
-- end
end
function showPixels(w,h,p)
 local row=""
 for y=0,h-1 do
  row=""
  for x=0,w-1 do
   row=row..string.format("%02X ",p[y*w+x])
  end
  print(row)
 end
end 

function fcb(name,w,h,p,f)
 local row=""
 local bitPairs=0
 s=string.format("%s.%d",name,f)
 print(s)
 for y=0,h-1 do
  binary=""
  for x=0,w-1 do
  n=y*w+x
   if     p[n] == 0 then binary=binary.."00"
   elseif p[n] == 1 then binary=binary.."01"
   elseif p[n] == 2 then binary=binary.."10"
   elseif p[n] == 3 then binary=binary.."11"
   else                  binary=binary.."11" end
   bitPairs=bitPairs+1
   if(bitPairs==4) then
    if string.len(row)>0 then
     row=row..","
    end
    row=row.."%"..binary
    binary=""
    bitPairs=0
   end
  end
  print("                fcb     "..row)
  row=""
 end
end

function showimage(name,cel)
	local img = cel.image:clone()

	local box=cel.bounds
	local sw=cel.sprite.width
	local sh=cel.sprite.height
	--print("* sprite."..cel.frameNumber.." Aseprite cell info: x,y,w,h: "..box.x..","..box.y..","..box.width..","..box.height)
	--print("* sprite."..cel.frameNumber.." frame data")
	local pixels={}
	for i=0,sw*sh do pixels[i]=0 end
	c=0
	for it in img:pixels() do
		--c=c+1
		--if c<100 then
			local px=it.x+box.x
			local py=it.y+box.y
			local pix=it()
			pixels[py*sw+px]=it()
			--print(it.x,it.y,px,py,pix)
		--end
	end

	--showPixels(sw,sh,pixels)
	fcb(name,sw,sh,pixels,cel.frameNumber)
end

function header(sprite)
 name=app.fs.fileTitle(sprite.filename)
 print(string.format("; Sprite   : %s",name))
 print(string.format("; Filename : %s",sprite.filename))
 s=string.format("%-15s fcb     $%02X,$%02X   ; (%d,%d) width,height of all frames",name,sprite.width,sprite.height,sprite.width,sprite.height)
 print(s)
end

local sprite=app.activeSprite
for i,sprite in ipairs(app.sprites) do
  header(sprite)
  for i,cel in ipairs(sprite.cels) do
    showimage(name,cel)
  end
end
