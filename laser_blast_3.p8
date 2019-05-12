pico-8 cartridge // http://www.pico-8.com
version 17
__lua__
function _init()
	globals = {}
	local g = globals

	-- initialize the player
	g.player = {}
	g.player.x = 56
	g.player.y = 56
	g.player.spr = 1
	g.player.spd = 2
	g.player.flip_x = true
	g.player.shots = {}
	g.player_camera_y = 0

	-- initialize camera position
	g.camera = {}
	g.camera.x = 0
	g.camera.y = 0

	-- initialize the sky height
	g.sky_hgt = 64
	
	-- initialize the game timer
	g.timer = 0

	--
	g.enemies = {}
	g.enemy_shots = {}

	g.time_of_day = "day"

	-- initialize the sun
	g.sun = {}
	g.sun.y = -20
	g.sun.clr = 10

	-- initialize the sky
	g.sky = {}
	g.sky.clr = 12

	-- initialize the clouds
	g.clouds = {}
	g.clouds.clr = 7

	g.ground = {}
	g.ground.clr = 11

	g.init_scale = 0.75
	g.scale_factor = 0.04

	g.horizontal_lines = {}


	for i=1,5 do
		g.horizontal_lines[i] = {}
		g.horizontal_lines[i].y = 64 + 16 * i
	end

	-- initialize the terrain
	g.terrain = {}
	g.terrain[1] = {}
	g.terrain[1].x = 40
	g.terrain[1].y = 64
	g.terrain[1].x_init = g.terrain[1].x
	g.terrain[1].scale = g.init_scale
	g.terrain[1].spr = 14

	g.terrain[2] = {}
	g.terrain[2].x = 72
	g.terrain[2].y = 64 + 32
	g.terrain[2].x_init = g.terrain[2].x
	g.terrain[2].scale = g.init_scale + 32 * g.scale_factor
	g.terrain[2].spr = 14

	g.terrain[3] = {}
	g.terrain[3].x = 104
	g.terrain[3].y = 64
	g.terrain[3].x_init = g.terrain[3].x
	g.terrain[3].scale = g.init_scale
	g.terrain[3].spr = 14

	g.terrain[4] = {}
	g.terrain[4].x = 24
	g.terrain[4].y = 64 + 32
	g.terrain[4].x_init = g.terrain[4].x
	g.terrain[4].scale = g.init_scale + 32 * g.scale_factor
	g.terrain[4].spr = 14
end

function _update()

	local g = globals
	-- horizontal player movement --
	-- left
	if(btn(0) and g.player.x > 0) then
		g.player.x -= g.player.spd

	-- right
	elseif(btn(1) and g.player.x + 24 < 128) then
		g.player.x += g.player.spd
	end

	-- vertical player movement --
	-- up
	if(btn(2) and g.player.y > 0) then
		g.player.y -= g.player.spd

	-- down
	elseif(btn(3) and g.player.y + 32 < 128) then
		g.player.y += g.player.spd
	end

	-- decrease sky size when the player is high up
	if(g.player.y <= 32 and g.camera.y > 0) then
		g.camera.y -= 1
		g.player_camera_y += 1

	-- increase sky size when the player is low down
	elseif(g.player.y + 24 >= 128-32 and g.camera.y < 32) then
		g.camera.y += 1
		g.player_camera_y -= 1
	end

	-- flip the player depending on which side they are on
	if(g.player.x >= (128-24)/2) then
		g.player.flip_x = true
	else
		g.player.flip_x = false
	end

	-- spawn player attack
	if(btnp(4)) then
		local s = {}
		s.x = g.player.x + 24 / 2 - 4
		s.y = g.player.y + 32 / 2 - 4 - 4
		s.camera_y = g.player_camera_y
		s.timer = 0
		add(g.player.shots, s)
	end

	-- update player shots so they travel to the background
	for i in all(g.player.shots) do
		i.timer += 0.05
		if(i.timer >= 0.05 * 75) then
			del(g.player.shots, i)
		end
	end

	-- update the sun and sky
	g.sun.y = g.camera.y - 20 + g.timer / 30

	-- evening
	if(g.sun.y >= g.camera.y + 45 and g.sun.y < g.camera.y + 70) then
		g.sun.clr = 9
		g.sky.clr = 10
		g.clouds.clr = 14
		g.ground.clr = 3
		g.time_of_day = "evening"

	-- night
	elseif(g.sun.y > g.camera.y + 72) then
		g.sky.clr = 0
		g.clouds.clr = 6
		g.ground.clr = 5
		g.time_of_day = "night"
	end

	for h in all(g.horizontal_lines) do
		h.y += 1
		if(h.y > 128) then h.y = 64 end
	end

	-- move the terrain forward
	for t in all(g.terrain) do
		t.y += 1
		if(t.x < 64) then
			t.x -= 0.25
			if(t.x <= -16) then
				t.x = t.x_init
			end
		else
			t.x += 0.25
			if(t.x >= 128+16) then
				t.x = t.x_init
			end
		end
		t.scale += g.scale_factor
		if(t.y > 128) then
			t.y = 64
			t.scale = g.init_scale
		end
	end

	-- update timer
	g.timer = (g.timer + 1) % 32000
end

function _draw()
	local g = globals
	cls()

	-- draw the backgrounds
	-- draw the sky
	rectfill(0, 0, 128, globals.sky_hgt + g.camera.y, g.sky.clr)

	-- draw the sun
	circfill(64, g.sun.y, 8, g.sun.clr)

	-- draw the cloud lines
	line(0, g.camera.y + 64 - 14, 128, g.camera.y + 64 - 14, g.clouds.clr)
	line(0, g.camera.y + 64 - 12, 128, g.camera.y + 64 - 12, g.clouds.clr)
	line(0, g.camera.y + 64 - 10, 128, g.camera.y + 64 - 10, g.clouds.clr)
	rectfill(0, g.camera.y + 64 - 8, 128, g.camera.y + 64 - 6, g.clouds.clr)
	rectfill(0, g.camera.y + 64 - 4, 128, g.camera.y + 64 - 2, g.clouds.clr)

	-- draw the ground
	rectfill(0, g.camera.y + 64, 128, 128, g.ground.clr)

	-- draw tiles for the ground
	line(-8, 128, 16, g.camera.y + 64, 0)
	line(24, 128, 32, g.camera.y + 64, 0)
	line(48, 128, 52, g.camera.y + 64, 0)
	line(64, 128, 64, g.camera.y + 64, 0)
	line(80, 128, 76, g.camera.y + 64, 0)
	line(104, 128, 96, g.camera.y + 64, 0)
	line(136, 128, 112, g.camera.y + 64, 0)


	for h in all(g.horizontal_lines) do
		line(0, g.camera.y + h.y, 128, g.camera.y + h.y, 0)
	end

	-- draw the terrain
	--[[for t in all(g.terrain) do
		--spr(t.spr, t.x, t.y + g.camera.y)
		sspr(t.spr*8, 0, 8, 8, t.x, t.y + g.camera.y, t.scale * 8, t.scale * 8)
	end]]

	-- draw player projectiles
	for i in all(g.player.shots) do
		sspr(13*8, 0, 8, 8, i.x, i.y + i.camera_y + g.camera.y, 8/ceil(i.timer), 8/ceil(i.timer))
	end

	-- draw the player
	palt(11, true)
	palt(0, false)
	if(g.time_of_day == "night") then pal(0, 1) end
	spr(g.player.spr+3*(flr(g.timer / 6) % 4), g.player.x, g.player.y, 3, 4, g.player.flip_x)
	if(g.time_of_day == "night") then pal(0, 0) end
	palt(11, false)
	palt(0, true)

end
__gfx__
00000000bbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbb008888000030000000000000
00000000bbbbbbbb1cc11bbbbbbbbbbbbbbbbbbb11c11bbbbbbbbbbbbbbbbbbb1cc11bbbbbbbbbbbbbbbbbbb11c11bbbbbbbbbbb088ee8800000030000000000
00700700bbbbbbb11c111bbbbbbbbbbbbbbbbbb11c111bbbbbbbbbbbbbbbbbb11c111bbbbbbbbbbbbbbbbbb1111c1bbbbbbbbbbb88eeee880700003000000000
00077000bbbbbbb111c11bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbb8ee77ee80030000000000000
00077000bbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbb8ee77ee80030070000000000
00700700bbbbbf91c11119fbbbbbbbbbbbbbbf91c11119fbbbbbbbbbbbbbbf91c11119fbbbbbbbbbbbbbbf91111119fbbbbbbbbb88eeee880000300000000000
00000000bbbbf991c1111990bbbbbbbbbbbbf991c1111990bbbbbbbbbbbbf991c1111990bbbbbbbbbbbbf99111111990bbbbbbbb088ee8800000300000000000
00000000bbbb001cc11119900bbbbbbbbbbb001c111119900bbbbbbbbbbb001cc11119900bbbbbbbbbbb0001c11119900bbbbbbb008888000000000000000000
00000000bbb0001c1111190000bbbbbbbbb0001c1111190000bbbbbbbbb0001c1111190000bbbbbbbbb00001c111190000bbbbbb000000000000000000000000
00000000bbb0001c11c199b00099bbbbbbb0011111c199b00099bbbbbbb0001c111199b00099bbbbbbb000b1c11119b00099bbbb000000000000000000000000
00000000bbb00011c11199bb097f9bbbbbb001c1111199bb097f9bbbbbb00011c1c199bb097f9bbbbbb000b1c11199bb097f9bbb000000000000000000000000
00000000bbb00b1111100bbbb9f7fbbbbbb00b1111100bbbb9f7fbbbbbb00b1111100bbbb9f7fbbbbbb00bb11c110bbbb9f7fbbb000000000000000000000000
00000000bbb00b1c11100bbbbb9f7bbbbbb00bbb00000bbbbb9f7bbbbbb00b1c11100bbbbb9f7bbbbbb00bbb11100bbbbb9f7bbb000000000000000000000000
00000000bbb00bb111000bbbbbbbbbbbbbb00bbb00000bbbbbbbbbbbbbb00bb111000bbbbbbbbbbbbbb00bbb00000bbbbbbbbbbb000000000000000000000000
00000000bbb099bb00000bbbbbbbbbbbbbb099bb00000bbbbbbbbbbbbbb099bb00000bbbbbbbbbbbbbb099bb00000bbbbbbbbbbb000000000000000000000000
00000000bbb999b9999999bbbbbbbbbbbbb999b9999999bbbbbbbbbbbbb999b9999999bbbbbbbbbbbbb999b9999999bbbbbbbbbb000000000000000000000000
00000000bbbb99b99ff999bbbbbbbbbbbbbb99b99ff999bbbbbbbbbbbbbb99b99ff999bbbbbbbbbbbbbb99b99ff999bbbbbbbbbb000000000000000000000000
00000000bbbbbbb9f999999bbbbbbbbbbbbbbbb9f999999bbbbbbbbbbbbbbbb9f999999bbbbbbbbbbbbbbbb9f999999bbbbbbbbb000000000000000000000000
00000000bbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbb000000000000000000000000
00000000bbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbb000000000000000000000000
00000000bbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbbbbbbbb999999999bbbbbbbbb000000000000000000000000
00000000bbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbb000000000000000000000000
00000000bbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbb000000000000000000000000
00000000bbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbbbbbbbbb00bbb000bbbbbbbbb000000000000000000000000
00000000bbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbb000000000000000000000000
00000000bbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbb000000000000000000000000
00000000bbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbbbbbbbb000bbbb00bbbbbbbbb000000000000000000000000
00000000bbbbbb00bbbbb000bbbbbbbbbbbbbb00bbbbb000bbbbbbbbbbbbbb00bbbbb000bbbbbbbbbbbbbb00bbbbb000bbbbbbbb000000000000000000000000
00000000bbbbb990bbbbb099bbbbbbbbbbbbb990bbbbb0998bbbbbbbbbbbb990bbbbb099bbbbbbbbbbbbb990bbbbb0998bbbbbbb000000000000000000000000
00000000bbbbb999bbbbb999bbbbbbbbbbbb89998bbb89998bbbbbbbbbbbb999bbbbb999bbbbbbbbbbbb89998bbb89998bbbbbbb000000000000000000000000
00000000bbbbbb99bbbbb99bbbbbbbbbbbbb88998bbb89988bbbbbbbbbbbbb99bbbbb99bbbbbbbbbbbbb88998bbb89988bbbbbbb000000000000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb878bbbbb878bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb878bbbbb878bbbbbbbb000000000000000000000000
00000aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
