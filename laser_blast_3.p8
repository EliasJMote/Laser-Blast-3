pico-8 cartridge // http://www.pico-8.com
version 17
__lua__
-- rectangular collision deteciton
function collision_detection(a,b)
	if(a.dx < b.dx + b.dw and
	a.dx + a.dw > b.dx and
	a.dy < b.dy + b.dh and
	a.dy + a.dh > b.dy) then
		return true
	else
		return false
	end
end

-- calculate an angle between two objects
function calculate_angle(a,b)
  -- theta is tan^-1 of delta y / delta x
  local delta_x = a.x - b.x
  local delta_y = a.y - b.y
  local theta = atan2(delta_x,delta_y)
  
  --[[if(delta_x >= 0) then
    if(delta_y >= 0) then
      theta = atan(delta_x)
    elseif(delta_y < 0) then
      theta = atan(delta_y/delta_x) + 1
    end
  elseif(delta_x < 0) then
    if(delta_y >= 0) then
      theta = atan(delta_y/delta_x) + 0.5
    elseif(delta_y < 0) then
      theta = atan(delta_y/delta_x) + 0.5
    end
  end]]
  
  return theta
end

function create_enemy(sx, sy, sw, sh, dx, dy, dw, dh, ai, g, frame)
	local e = {}
	e.sx = sx or 0
	e.sy = sy or 0
	e.sw = sw or 0
	e.sh = sh or 0
	e.dx = dx or 0
	e.dy = dy or 0
	e.x = e.dx
	e.y = e.dy
	e.dy_init = e.dy
	e.dw = dw or 0
	e.dh = dh or 0
	e.dw_init = e.dw
	e.dh_init = e.dh
	e.frame = frame or 1
	e.scale = 0
	e.depth = 3
	e.ai = ai or 1
	e.phase = 1
	e.timer = 0
	e.health = 10
	add(g.enemies, e)
end

function create_enemy_shot(g, e)
	local s = {}
	s.x = e.dx + e.dw / 2
	s.y = e.dy + e.dh / 2
	local p = {}
	p.x = g.player.x + 12 / 2
	p.y = g.player.y + 24 / 2
	s.angle = calculate_angle(s,p)
	printh(s.angle)
	s.spd = 2
	add(g.enemy_shots, s)
end

function update_enemies(g)
	for e in all(g.enemies) do
		-- for ai pattern one (approach, leave, teleport)
		if(e.ai == 1) then
			-- update based on phase
			if(e.phase == 1) then
				if(e.scale <= 1) then
					e.scale += 0.015
				else
					e.scale = 1
					e.phase = 2
				end
			elseif(e.phase == 2) then
				if(e.timer == 0) then
					-- spawn random enemy attack
				elseif(e.timer >= 90) then
					e.timer = 0
					e.phase = 3
				end
				e.timer += 1
			elseif(e.phase == 3) then
				if(e.scale >= 0) then
					e.scale -= 0.015
				else
					e.scale = 0
					e.phase = 1
					e.dx = flr(rnd(80)) + 30
				end
			end

		elseif(e.ai == 2) then

			if(e.phase == 1) then
				e.dx -= 1
				if(e.dx <= 0) then
					e.dx = 0
					e.phase = 2
				end
			elseif(e.phase == 2) then
				e.dx += 1
				if(e.dx >= 128-16) then
					e.dx = 128-16
					e.phase = 1
				end
			end

			-- move up and down in a sine wave
			e.dy = e.dy_init + 10*sin(e.timer/50)

			-- approaching
			if(e.scale < 1) then
				e.scale += 0.015

			-- arrival
			else
				e.scale = 1

				-- shoot projectiles periodically
				if(e.timer % 90 == 0) then
					create_enemy_shot(g,e)
				end
			end
			--printh("Yes")

			-- update enemy timer
			e.timer += 1
		end

		-- update depth based on scale
		if(e.scale >= 0.66) then
			e.depth = 3
		elseif(e.scale >= 0.33) then
			e.depth = 2
		else
			e.depth = 1
		end

		-- update dw and dh
		e.dw = e.scale * e.dw_init
		e.dh = e.scale * e.dh_init

		-- collision detection
		-- temporarily add the camera position to enemy's y position
		-- since the player's position is not relative to the camera
		e.dy += g.camera.y

		-- for each player shot
		for s in all(g.player.shots) do
			if(e.depth == s.depth and collision_detection(e,s)) then
				-- delete shot
				del(g.player.shots,s)

				-- create particle effect

				-- lower enemy health
				e.health -= 1
			end
		end

		-- restore the enemy's position to normal
		e.dy -= g.camera.y

		-- eliminate the enemy when defeated
		if(e.health <= 0) then
			del(g.enemies,e)
		end
	end

	update_enemy_shots(g)
end

function update_enemy_shots(g)
	for s in all(g.enemy_shots) do
		s.x -= s.spd * cos(s.angle)
		s.y -= s.spd * sin(s.angle)
	end
end

function draw_enemies(g)
	palt(5, true)
	palt(0, false)
	for e in all(g.enemies) do
		--sspr(e.sx+e.sw*(flr(g.timer/3)%e.frame), e.sy, e.sw, e.sh, e.dx, g.camera.y + e.dy, e.dw*e.scale, e.dh*e.scale)
		sspr(e.sx+e.sw*(flr(g.timer/3)%e.frame), e.sy, e.sw, e.sh, e.dx, g.camera.y + e.dy, e.dw, e.dh)
		--sspr(e.sx, e.sy, e.sw, e.sh, e.dx, e.dy, e.dw*e.scale, e.dh*e.scale)
	end
	palt(5, false)
	palt(0, true)
	draw_enemy_shots(g)
end

function draw_enemy_shots(g)
	for s in all(g.enemy_shots) do
		if(g.timer % 4 <= 1) then
			circfill(s.x, g.camera.y + s.y, 3, 8)
		else
			circfill(s.x, g.camera.y + s.y, 3, 12)
		end
	end
end

function update_player(g)
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

	-- flip the player depending on which side they are on
	if(g.player.x >= (128-24)/2) then
		g.player.flip_x = true
	else
		g.player.flip_x = false
	end

	-- spawn player attack
	if(btnp(4)) then
		local s = {}
		s.dx = g.player.x + 24 / 2 - 4
		s.dy = g.player.y + 32 / 2 - 4 - 4
		s.camera_y = g.player_camera_y
		s.scale = 1
		s.dw = s.scale * 8
		s.dh = s.scale * 8
		add(g.player.shots, s)
	end

	-- update player shots so they travel to the background
	for s in all(g.player.shots) do
		-- shot travels to background, so decrease scale
		s.scale -= 0.05

		-- update depth based on scale
		if(s.scale >= 0.66) then
			s.depth = 3
		elseif(s.scale >= 0.33) then
			s.depth = 2
		else
			s.depth = 1
		end

		-- update width and height based on scale
		s.dw = s.scale * 8
		s.dh = s.scale * 8
		if(s.scale <= 0) then
			del(g.player.shots, s)
		end
	end
end

function draw_player(g)
	-- draw player projectiles
	for s in all(g.player.shots) do
		sspr(13*8, 0, 8, 8, s.dx, s.dy + s.camera_y + g.camera.y, s.dw, s.dh)
	end

	-- draw the player's shadow
	if not (g.player.flip_x) then
		circfill(g.player.x + 10, 123, 4, 0)
	else
		circfill(g.player.x + 13, 123, 4, 0)
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

function update_environment(g)
	-- decrease sky size when the player is high up
	if(g.player.y <= 32 and g.camera.y > 0) then
		g.camera.y -= 1
		g.player_camera_y += 1

	-- increase sky size when the player is low down
	elseif(g.player.y + 24 >= 128-32 and g.camera.y < 32) then
		g.camera.y += 1
		g.player_camera_y -= 1
	end

	-- day/night cycle
	-- update the sun and sky
	if(g.time_of_day ~= night) then
		--g.sun.y += 0.3
		g.sun.y += 0.02
	end

	-- transition to evening
	if(g.time_of_day == "day" and g.sun.y >= 45 and g.sun.y < 70) then
		g.sun.clr = 9
		g.sky.clr = 10
		g.clouds.clr = 14
		g.ground.clr = 3
		g.time_of_day = "evening"

	-- transition to night
	elseif(g.time_of_day == "evening" and g.sun.y > 72) then
		g.sky.clr = 0
		g.clouds.clr = 6
		g.ground.clr = 5
		g.time_of_day = "night"
	end

	-- move horizontal lines forward
	for h in all(g.horizontal_lines) do
		h.y += 1
		if(h.y > 128) then h.y = 64 end
	end
end

function draw_environment(g)
	-- draw the sky
	rectfill(0, 0, 128, globals.sky_hgt + g.camera.y, g.sky.clr)

	-- draw the sun
	circfill(64, g.camera.y  + g.sun.y, 8, g.sun.clr)

	-- draw the cloud lines
	line(0, g.camera.y + 64 - 14, 128, g.camera.y + 64 - 14, g.clouds.clr)
	line(0, g.camera.y + 64 - 12, 128, g.camera.y + 64 - 12, g.clouds.clr)
	line(0, g.camera.y + 64 - 10, 128, g.camera.y + 64 - 10, g.clouds.clr)
	rectfill(0, g.camera.y + 64 - 8, 128, g.camera.y + 64 - 6, g.clouds.clr)
	rectfill(0, g.camera.y + 64 - 4, 128, g.camera.y + 64 - 2, g.clouds.clr)

	-- draw the stars
	if(g.time_of_day == "night") then
		spr(14+flr(g.timer/8)%2, 64, g.camera.y + 32)
		spr(14+flr(g.timer/8)%2, 32, g.camera.y + 16)
		spr(14+flr(g.timer/8)%2, 18, g.camera.y + 30)
		spr(14+flr(g.timer/8)%2, 30, g.camera.y - 5)
		spr(14+flr(g.timer/8)%2, 47, g.camera.y - 20)
		spr(14+flr(g.timer/8)%2, 110, g.camera.y + 10)
		spr(14+flr(g.timer/8)%2, 52, g.camera.y)
		spr(77, 80, g.camera.y, 3, 4)
	end

	-- draw the ground
	rectfill(0, g.camera.y + 64, 128, 128, g.ground.clr)

	-- draw perspective lines
	line(-8, 128, 16, g.camera.y + 64, 0)
	line(24, 128, 32, g.camera.y + 64, 0)
	line(48, 128, 52, g.camera.y + 64, 0)
	line(64, 128, 64, g.camera.y + 64, 0)
	line(80, 128, 76, g.camera.y + 64, 0)
	line(104, 128, 96, g.camera.y + 64, 0)
	line(136, 128, 112, g.camera.y + 64, 0)

	-- draw horizontal lines
	for h in all(g.horizontal_lines) do
		line(0, g.camera.y + h.y, 128, g.camera.y + h.y, 0)
	end
end

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

	-- initialize the enemies
	g.enemies = {}
	--create_enemy(0, 32, 20, 32, 56, 48, 20, 32, 1, g)
	--create_enemy(24, 32, 24, 32, 80, 48, 24, 32, 1, g, 2)
	create_enemy(72, 32, 16, 16, 32, 48, 16, 16, 2, g, 1)

	-- initialize the enemy shots
	g.enemy_shots = {}

	-- initialize the time of day
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

	-- initialize horizontal lines
	g.horizontal_lines = {}
	for i=1,5 do
		g.horizontal_lines[i] = {}
		g.horizontal_lines[i].y = 64 + 16 * i
	end
end

function _update()

	local g = globals

	-- update the player
	update_player(g)

	-- update enemies
	update_enemies(g)

	-- update environment
	update_environment(g)

	-- move the terrain forward
	--[[for t in all(g.terrain) do
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
	end]]

	-- update game timer
	g.timer = (g.timer + 1) % 32000
end

function _draw()
	local g = globals
	cls()

	-- draw the backgrounds
	draw_environment(g)

	-- draw the terrain
	--[[for t in all(g.terrain) do
		--spr(t.spr, t.x, t.y + g.camera.y)
		sspr(t.spr*8, 0, 8, 8, t.x, t.y + g.camera.y, t.scale * 8, t.scale * 8)
	end]]
	

	-- draw the enemies
	draw_enemies(g)

	-- draw the player
	draw_player(g)

end
__gfx__
00000000bbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbb008888000000000000000000
00000000bbbbbbbb1cc11bbbbbbbbbbbbbbbbbbb11c11bbbbbbbbbbbbbbbbbbb1cc11bbbbbbbbbbbbbbbbbbb11c11bbbbbbbbbbb088ee8800007000007070700
00700700bbbbbbb11c111bbbbbbbbbbbbbbbbbb11c111bbbbbbbbbbbbbbbbbb11c111bbbbbbbbbbbbbbbbbb1111c1bbbbbbbbbbb88eeee880007000000777000
00077000bbbbbbb111c11bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbbbbbbbbb111111bbbbbbbbbbb8ee77ee80777770007777700
00077000bbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbbbbbbbb91c1111fbbbbbbbbbb8ee77ee80007000000777000
00700700bbbbbf91c11119fbbbbbbbbbbbbbbf91c11119fbbbbbbbbbbbbbbf91c11119fbbbbbbbbbbbbbbf91111119fbbbbbbbbb88eeee880007000007070700
00000000bbbbf991c1111990bbbbbbbbbbbbf991c1111990bbbbbbbbbbbbf991c1111990bbbbbbbbbbbbf99111111990bbbbbbbb088ee8800000000000000000
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
55555555222255555555000055555555588885555555555555555555588885555555555555588885522225550022220000000000000000000000100100000000
5555555222222555555500005555555588f8e855555555555555555588f8e8555555555555558888822255550288882000000000000000000000100000000000
555555222002225555550000555555558fff885555555555555555558fff88555555555555555888882555552822228200000000000000010000700010000000
555555220000225555550000555555558ffff8555555555555ee55558ffff85555ee555555555888882555552828828200000000000000000101710000000000
5555522000000225555500005555eee58ffff85eee5555555e88eee58ffff85eee88e55555558888888255552828828200000000000000000001710010000000
555552200000022555550000555e888e33f333e888e55555e8ee888e33f333e888ee8e555558887887822555282222820000000000000000001171b000000000
55552200800800225555000055e8ee3333333333ee8e55555e88ee3333333333ee88e555558588888222525502888820000000000000001000b1711001000000
5555220000000022555500005e8e88f33333333f88e8e5555e8888f33333333f8888e5555555587887255555002222000000000000000000011b7b1100000000
522222000000002222250000e8e888ff333333ff888e8e5555ee88ff333333ff88ee55555555558882555555000000000000000000000000011b7b1100100000
2220220000000022022200005e88eff33333333ffe88e5555555eff33333333ffe55555555555588825555550000000000000000000001001b1b7b1110000000
2200222000000222002200005e8e5ff53333335ff5e8e55555555ff53333335ff55555555555558882555555000000000000000000000001b1b777b1b1000000
20000022222222000002000055e55ff553f3f55ff55e555555555ff553f3f55ff555555555555588825555550000000000000000000100011b77777b11010000
2000008000000800000200005555fff55ffff55fff5555555555fff55ffff55fff5555555558858882588555000000000000000000000011b7cc7cc7b1100000
2000000a0000a000000200005555ff555ffff555ff5555555555ff555ffff555ff555555588558888225588500000000000000000000011b77cc7cc77b110010
20000000aaaa0000000200005555ff555ffff555ff5555555555ff555ffff555ff5555555555580820255555000000000000000000011bb7ccc777ccc7b11100
2000000000000000000200005555ff5533333355ff5555555555ff5533333355ff55555555555588225555550000000000000000011777777777777777777711
2000000020020000000200005555ff5533333355ff5555555555ff5533333355ff5555550000000000000000000000000000000000011bb7ccc777ccc7b11100
520020002002000200250000555555553333333555555555555555553333333555555555000000000000000000000000000000000000011b77cc7cc77b110000
520020002002000200250000555555533333333555555555555555533333333555555555000000000000000000000000000000000000001bb7cc7cc7b1100100
52020002000020002025000055555553333333355555555555555553333333355555555500000000000000000000000000000000000100011b77777b1b000001
222000020000200002220000555555533f333f3555555555555555533f333f35555555550000000000000000000000000000000000000001b1b777b111010000
200000020000200000020000555555553f553ff555555555555555553f553ff5555555550000000000000000000000000000000000001000111b7b1110000000
20000020000002000002000055555555ff55fff55555555555555555ff55fff5555555550000000000000000000000000000000000000010011b7b1b00000000
52000020000002000025000055555555ff55fff55555555555555555ff55fff555555555000000000000000000000000000000000000000001b17b1100100000
52000200200200200025000055555555ff55fff55555555555555555ff55fff55555555500000000000000000000000000000000000000000011711000000000
5200200020020002002500005555555fff555ff5555555555555555fff555ff555555555000000000000000000000000000000000000000000117b1000000000
2022000020020000220200005555555fff555ff5555555555555555fff555ff55555555500000000000000000000000000000000000000001001710001000000
2000000200002000000200005555555fff555ff5555555555555555fff555ff55555555500000000000000000000000000000000000000000001710000000000
2000002000000200000200005555555ff5555fff555555555555555ff5555fff5555555500000000000000000000000000000000000000000000700000000000
22000200000000200022000055555533f5555f335555555555555533f5555f335555555500000000000000000000000000000000000000000100100100000000
52222000000000022225000055555533355553335555555555555533355553335555555500000000000000000000000000000000000000000000100000000000
55222222222222222255000055555553355553355555555555555553355553355555555500000000000000000000000000000000000000000000000000000000
