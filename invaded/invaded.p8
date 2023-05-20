pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- test game
-- by mouring cat

function fire(x,y)
   laser = {x=x,y=y}   
   add(lasers,laser)
   sfx(0)
end

function create_wave(size)
   for i=1,size do create_enemy(rnd(128),0) end
end

function create_enemy(x,y)
   enemy={x=x,y=y,speed=rnd(1)+1,sprite=2}
   add(enemies,enemy)
end

function enemy_collision(x,y,enemy)
   if x>=enemy.x and x<=enemy.x+8 and y>=enemy.y and y<=enemy.y+8 then
      return true
   end
   return false
end

function _init()
  player = {x=20,y=64,sprite=1}
  lasers = {}
  enemies = {}
  score = 0
  wavetimer = 0
  waveintensity = 5

  create_wave(rnd(6)+5)
end

function _update()
  wavetimer+=1
  
  if not gameover then
    if btn(0) then
      player.x-=2
    end
    if btn(1) then
      player.x+=2 
    end
    if btn(2) then
      player.y-=2
    end
    if btn(3) then
      player.y+=2
    end
    if btnp(4) then
      fire(player.x+5,player.y+3)
    end
  end
  
  player.x=mid(0,player.x,120)
  player.y=mid(0,player.y,120)
  
  for enemy in all(enemies) do
    enemy.y+=enemy.speed   
    for laser in all(lasers) do
      if enemy_collision(laser.x,laser.y,enemy) then
        del(enemies,enemy)
        del(lasers,laser)
        score+=100
        sfx(1)
      end
    end
    if enemy_collision(player.x+4,player.y+4,enemy) then
      gameover = true
      sfx(2)
    end
    if enemy.x<-8 then
      del(enemies,enemy)
    end    
  end
  
  
  for laser in all(lasers) do
    laser.y-=3 
    if laser.y<0 then
      del(lasers,laser)
    end
  end

  if wavetimer==90 then
    create_wave(rnd(6)+waveintensity)
    wavetimer=0
    waveintensity+=1
  end
end

function _draw()
  cls()
  
  if not gameover then
    spr(player.sprite,player.x,player.y)
  end
  
  for enemy in all(enemies) do --draw enemies
    spr(enemy.sprite,enemy.x,enemy.y)
  end
  
  for laser in all(lasers) do --draw lasers
    rect(laser.x,laser.y,laser.x+2,laser.y+1,8)
  end
  
  if gameover then
    print('game over',50,64,7)
  end
   
  print('score: '..score,2,2,7)
end
__gfx__
00000000000000000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000088000999aa99900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000888800999aa99900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700008998000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088998800099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000035150000000000029150000002315000000000001a15000000000001215000000091500000003150000000000000000000000000000000000000000000000000000000000000
001000000065004650046500a6500465007650046500165000000000000260004600086000e600000000b60001600000000b6001160007600016000b600000000260000000000000000000000000000000000000
00100000186500e650086500000003650000000065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
