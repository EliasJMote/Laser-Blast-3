pico-8 cartridge // http://www.pico-8.com
version 17
__lua__
function _init()
	globals = {}

	-- initialize the player
	globals.player = {}
	globals.player.x = 56
	globals.player.y = 56
	globals.player.spr = 1
	globals.player.spd = 2

	-- initialize the sky height
	globals.sky_hgt = 64

	globals.player.flip_x = true

	globals.timer = 0
end

function _update()

	local g = globals

	-- horizontal player movement --
	-- left
	if(btn(0) and g.player.x > 0) then
		g.player.x -= g.player.spd

	-- right
	elseif(btn(1) and g.player.x + 16 < 128) then
		g.player.x += g.player.spd
	end

	-- vertical player movement --
	-- up
	if(btn(2) and g.player.y > 0) then
		g.player.y -= g.player.spd

	-- down
	elseif(btn(3) and g.player.y + 24 < 128) then
		g.player.y += g.player.spd
	end

	-- decrease sky size when the player is high up
	if(g.player.y <= 32 and g.sky_hgt > 32) then
		g.sky_hgt -= 1

	-- increase sky size when the player is low down
	elseif(g.player.y + 24 >= 128-32 and g.sky_hgt < 128-32) then
		g.sky_hgt += 1
	end

	-- flip the player depending on which side they are on
	if(g.player.x >= (128-24)/2) then
		g.player.flip_x = true
	else
		g.player.flip_x = false
	end

	g.timer += 1
end

function _draw()
	local g = globals
	cls()

	-- draw the backgrounds
	-- draw the sky
	--rectfill(0, 0, 128, globals.sky_hgt, 12)

	line(0, g.sky_hgt - 14, 128, g.sky_hgt - 14, 7)
	line(0, g.sky_hgt - 12, 128, g.sky_hgt - 12, 7)
	line(0, g.sky_hgt - 10, 128, g.sky_hgt - 10, 7)
	rectfill(0, g.sky_hgt - 8, 128, g.sky_hgt - 6, 7)
	rectfill(0, g.sky_hgt - 4, 128, g.sky_hgt - 2, 7)


	-- draw the grass
	rectfill(0, g.sky_hgt, 128, 128, 3)

	-- draw the player
	--[[for i=0,3 do
		for j=0,2 do
			if(flr(g.timer / 6) % 4 == 0) then
				spr(g.player.spr+16*i+j+0, g.player.x+8*j, g.player.y+8*i, 1, 1, g.player.flip_x)
			elseif(flr(g.timer / 6) % 4 == 1) then
				spr(g.player.spr+16*i+j+3, g.player.x+8*j, g.player.y+8*i, 1, 1, g.player.flip_x)
			elseif(flr(g.timer / 6) % 4 == 2) then
				spr(g.player.spr+16*i+j+6, g.player.x+8*j, g.player.y+8*i, 1, 1, g.player.flip_x)
			else
				spr(g.player.spr+16*i+j+9, g.player.x+8*j, g.player.y+8*i, 1, 1, g.player.flip_x)
			end
		end
	end]]

	spr(g.player.spr+3*(flr(g.timer / 6) % 4), g.player.x, g.player.y, 3, 4, g.player.flip_x)

end
__gfx__
00000000000000001111000000000000000000001111000000000000000000001111000000000000000000001111000000000000000000000000000000000000
00000000000000001cc1100000000000000000001cc1100000000000000000001cc1100000000000000000001cc1000000000000000000000000000000000000
00700700000000011c11100000000000000000011c11100000000000000000011c11100000000000000000011111100000000000000000000000000000000000
000770000000000111c11000000000000000000111111000000000000000000111c1100000000000000000011111100000000000000000000000000000000000
0007700000000091c1111f000000000000000091c11119000000000000000091c1111f0000000000000000a1c1111f0000000000000000000000000000000000
0070070000000f91c11119f00000000000000991c11119f00000000000000f91c11119f00000000000000f91111119f000000000000000000000000000000000
000000000000f991c1111999000000000000fa91c1111f99000000000000f991c1111999000000000000f9f111111f9900000000000000000000000000000000
000000000000991cc1111999900000000000991c11111999f00000000000991cc11119999000000000009f9c1111199f90000000000000000000000000000000
000000000009991c11111999990000000009f91c111119f9990000000009991c11111999990000000009999c1111199999000000000000000000000000000000
000000000009991c11c19909991100000009911111c19909991100000009991c11c19909991100000009990c11c1190999110000000000000000000000000000
0000000000099911c111990091c11000000991c11111990091c1100000099911c111990091c11000000999011111990091c11000000000000000000000000000
000000000009901111199900011c10000009a01c1c199900011c10000009901111199900011c10000009900c11119900011c1000000000000000000000000000
00000000000f901c1119900000117000000f90009999900000117000000f901c1119900000117000000ff000cc19900000117000000000000000000000000000
00000000000f90011199900000000000000990009999900000000000000f90011199900000000000000f90009999900000000000000000000000000000000000
00000000000911009999900000000000000911009999900000000000000911009999900000000000000911009999900000000000000000000000000000000000
00000000000111009999900000000000000111009999900000000000000111009999900000000000000111009999900000000000000000000000000000000000
0000000000001101111111000000000000001101c111110000000000000011011111110000000000000011011111110000000000000000000000000000000000
0000000000000001c1cc1100000000000000000c11cc11000000000000000001c1cc1100000000000000000c11c1110000000000000000000000000000000000
000000000000000c11111110000000000000000c11111c00000000000000000c1111111000000000000000011c111c1000000000000000000000000000000000
00000000000000c111c1c11000000000000000c111c1111000000000000000c111c1c11000000000000000111111c11000000000000000000000000000000000
0000000000000011c11111c00000000000000c111c1c11100000000000000011c11111c00000000000000011c11c11c000000000000000000000000000000000
00000000000000c11cc11c100000000000000111c111110000000000000000c11cc11c1000000000000000c111c11cc000000000000000000000000000000000
00000000000000099000999000000000000000099000999000000000000000099000999000000000000000099000999000000000000000000000000000000000
000000000000000f90009990000000000000000f90009990000000000000000f90009990000000000000000f9000999000000000000000000000000000000000
000000000000009990000f90000000000000009990000f90000000000000009990000f90000000000000009990000f9000000000000000000000000000000000
00000000000000f990000f9000000000000000f990000f9000000000000000f990000f9000000000000000f990000f9000000000000000000000000000000000
00000000000000f99000099000000000000000f99000099000000000000000f99000099000000000000000f99000099000000000000000000000000000000000
00000000000000990000099900000000000000990000099900000000000000990000099900000000000000990000099900000000000000000000000000000000
000000000000011900000911000000000000c11900000911c00000000000011900000911000000000000c11900000911c0000000000000000000000000000000
000000000000011100000111000000000000c111c000c111c00000000000011100000111000000000000c111c000c111c0000000000000000000000000000000
000000000000001100000110000000000000cc11c000c11cc00000000000001100000110000000000000cc11c000c11cc0000000000000000000000000000000
0000000000000000000000000000000000000c7c00000c7c0000000000000000000000000000000000000c7c00000c7c00000000000000000000000000000000