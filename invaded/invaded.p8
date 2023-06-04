pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- invaded game
-- by mouring cat

function upd_game() 
 update_player()

 if #enemies==0 then 
  if delay>0 then
   delay-=1
  else
   do_wave(wave)
   delay=50
   if not start then
    mute()
    if wave%(#wave_set)==0 then
     -- we shall take over the earth
     say("_/y/-1.26/uw/-1.67/_/k/-1.18/ae/-1.06/n/-1.13/n/-1.30/aa/-1.69/_/t/-1.22/hh/-1.27/3/ow/-1.12/l/-1.72/_/d/-1.10/aw/-1.69/_/t/-1.15/f/-1.54/er/-1.39/3/eh/-1.05/-3/v/-1.18/-3/er")
    else
     -- new wave
     say("_/n/-1.26/3/uw/-1.03/-3/w/1.79/-3/ey/1.07/-3/v")
    end
   else
    -- we shall take over the earth
    mute()
    say("_/w/-1.25/iy/sh/-1.29/ae/-1.07/l/-1.71/_/t/-1.15/3/ey/-1.68/_/k/-1.23/ow/-1.05/v/-1.55/er/dh/-1.47/ah/-1.01/-3/er/1.13/-3/th")
   end
   if not start then
   	wave+=1
   else
    start=false
   end
  end
 end
end

function drw_game()
 draw_player()
 draw_points()
end

function upd_gameover()
 mainmenu=true
 player.x=-100
 player.y=-100
 init_gameover()

 if #enemies==0 then
  do_wave(wave)
 end

 if btnp(🅾️) then
  _upd=upd_game
  _drw=drw_game
  newgame()
  mainmenu=false
 end
end

function drw_gameover()
 drawind()
end

function init_gameover()
 if gameover then
  gover=addwind(44,30,52,13, {
   " game over"
  })
 end
 invwind=addwind(44,44,52,28,{
  "  invaded",
  "",
  "🅾️ new game",
 })
end

function _init()
 spk8_pitch,spk8_rate,spk8_volume,spk8_quality,spk8_intonation,spk8_if0,spk8_shift,spk8_bandwidth,spk8_whisper=140,1,1,.5,10,10,1,1,1
 newgame()
 _upd=upd_gameover
 _drw=drw_gameover
 wind={}
 wave_set={
  {1,1,0}, -- 2
  {2,2,0}, -- 4
  {2,2,2}, -- 6
  {4,2,2}, -- 8
  {4,3,3}, -- 10
  {5,5,2}, -- 12
  {6,5,3}  -- 14
 }
end

function _update()
 speako8()
 update_stars()
 update_enemies()
 update_lasers()
 _upd() 
end

function _draw()
 cls()
 draw_starfield()
 draw_enemies()
 draw_lasers()
 _drw()
 ui_overlay()
end
-->8
-- emeny logic

function create_enemy(x,y,t)
 if t==1 then
  add(enemies,{
   x=x,
   y=y,
   by=rnd(50)+50,
   shot=flr(rnd(10))+20,
   sprite=2,
   wepcol=9,
   move=_1_move,
   points=100
  })
 elseif t==2 then
  add(enemies,{
   x=x,
   y=y,
   by=rnd(80)+20,
   shot=flr(rnd(10))+20,
   sprite=3,
   wepcol=11,
   move=_2_move,
   points=125
  })
 elseif t==3 then
  add(enemies,{
   x=x,
   y=y,
   shot=flr(rnd(10))+20,
   sprite=4,
   wepcol=2,
   move=_3_move,
   points=500
  })
 end
end

function move_bounce_y(self,y,ly)
 if self.y<ly then
  self.up=false
  self.by=rnd(50)+50
  self.y+=y
 elseif self.up then
  self.y-=y
 elseif self.y>self.by then
  self.y-=y
  self.up=true
 else
  self.y+=y
 end
end

function move_bounce_x(self,x)
 if self.x<5 then
  self.x+=x
  self.left=true
 elseif self.x>120 then
  self.x-=x
  self.left=false
 elseif self.left then
  self.x+=x
 else
  self.x-=x
 end
end

function move_loop_x(self,x)
  if self.x>128 then
   self.x=-10
   self.y=flr(rnd(20))+8
  else
   self.x+=x
  end
end

function _1_move(self)
 move_bounce_y(self,rnd(2)+1,-20)
end

function _2_move(self)
 local pos=1
 if flr(rnd())>=0.2 then
   pos=-1
 end
 move_bounce_y(self,rnd(3)+1,5)
 move_bounce_x(self,pos*flr(rnd(2)))
end

function _3_move(self)
 move_loop_x(self,flr(rnd(3))+1)
end

function do_wave()
 local w=wave%#wave_set
 local c=wave\#wave_set+1
 -- hacks
 if not start then
  w+=1
 end
 if w==0 then
  w=#wave_set
  c-=1
 end

 for e=1,wave_set[w][1]*c do
  create_enemy(rnd(124),0,1)
 end
 for e=1,wave_set[w][2]*c do
  create_enemy(rnd(124),0,2)
 end
 for e=1,wave_set[w][3]*c do
  create_enemy(-10,flr(rnd(20))+20,3)
 end
end

function draw_points()
 for e in all(points) do
  print(e.p, e.x, e.y)
  if e.c==0 then 
   del(points,e)
  end
  e.c-=1
 end
end

function delete_enemy(e)
 del(enemies,e)
 score+=e.points
 add(points,{
  x=e.x,
  y=e.y,
  p="+"..e.points,
  c=10
  })
 sfx(1)
end

function update_enemies()
 for e in all(enemies) do
  e:move()
  e.shot-=1
  if collision_test(player.x+4,player.y+4,e) then
   dec_sheilds(enemies,e)
  end
  if e.y<100 and e.shot<=0 then
   fire(e.x,e.y,rnd(2)+2,"enemy",e.wepcol)
   e.shot=flr(rnd(10))+20
  end
 end
end

function draw_enemies()
 for e in all(enemies) do
  spr(e.sprite,e.x,e.y)
 end
end
-->8
-- user interface

function ui_overlay()
 print('score: '..score,2,2,7)
 print('wave: '..wave,60,2,7)
 for i=1,3 do
  local sp=5
  if i<=shields then
   sp=6
  end
  spr(sp,100+(i-1)*9,1)
 end
end
-->8
-- weapons

function fire(x,y,s,dir,wepcol)
 laser={
  x=x,
  y=y,
  s=s,
  dir=dir,
  wepcol=wepcol
 }   
 add(lasers,laser)
 if dir=="player" then
  sfx(0)
 elseif dir=="enemy" then
  sfx(3)
 end
end

function update_lasers()
 for l in all(lasers) do
  if l.dir=="player" then
   l.y-=l.s+1
   for e in all(enemies) do
    if collision_test(l.x,l.y,e) then
     delete_enemy(e)
     del(lasers,l)
    end
   end
  elseif l.dir=="enemy" then
   l.y+=l.s
   if collision_test(l.x,l.y,player) then
    dec_sheilds(lasers,l)
   end
  end
  if l.y<8 or l.y>128 then
   del(lasers,l)
  end
 end
end

function draw_lasers()
 for l in all(lasers) do
  rect(l.x,l.y,l.x+2,l.y+1,l.wepcol)
 end
end
-->8
-- player

function update_player()
 gundelay-=1
 if btn(⬅️) then
  player.x-=2
 end
 if btn(➡️) then
  player.x+=2 
 end
 if btn(⬆️) then
  player.y-=2
 end
 if btn(⬇️) then
  player.y+=2
 end
 if gundelay<=0 and btnp(❎) then
   fire(player.x+3,player.y+3,3,"player",8)
   gundelay=8
 end
 player.x=mid(0,player.x,120)
 player.y=mid(0,player.y,120)
 if immume>0 then
  immume-=1
 end
end

function dec_sheilds(ps,p)
 if immume==0 then
  shields-=1
  if shields<0 then
   game_over()
  end
  del(ps,p)
  sfx(4)
  immume=4
 end
end

function draw_player()
 if shields>0 then
  spr(shields+6,player.x,player.y-5)
 end
 spr(player.sprite,player.x,player.y)
end
-->8
-- tools

function collision_test(x,y,p)
 if x>=p.x and 
    x<=p.x+8 and 
    y>=p.y and 
    y<=p.y+8 then
  return true
 end
 return false
end

function game_over()
 gameover=true
 sfx(2)
 _upd=upd_gameover
 _drw=drw_gameover
 
 -- ha ha ha the earth belongs to us
 mute()
 say("_/hh/-1.24/3/aa/hh/-1.24/3/aa/hh/-1.24/3/aa/dh/-1.47/ah/-1.38/3/er/-1.09/th/-1.64/_/b/-1.60/ih/-1.07/l/-1.34/3/ao/-1.11/ng/-1.18/z/-1.71/_/t/-1.14/uw/-1.01/-3/ah/1.12/-3/s")
end

function newgame()
 player = {
  x=20,
  y=110,
  sprite=1
 }
 points={}
 lasers={}
 enemies={}
 score=0
 shields=3
 immume=0
 start=true
 wave=1
 init_stars()
 delay=20
 gundelay=0
end

function draw_starfield()
 for i=1,#stars do
  local ms=stars[i]
  local scol=6
  
  if ms.spd<1 then
   scol=1
  elseif ms.spd<1.5 then
   scol=13
  end
  pset(ms.x,ms.y,scol)
 end
end

function init_stars()
 stars={} 
 for i=1,50 do
  add(stars,{
   x=flr(rnd(128)),
   y=flr(rnd(128)),
   spd=rnd(1.5)+0.5
  })
 end 
end

function update_stars()
 for i=1,#stars do
  local ms=stars[i]
  ms.y+=ms.spd
  if ms.y>128 then
   ms.y-=128
  end
 end
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.cur then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end
   print(txt,wx,wy,c)
   if i==w.cur then
    spr(255,wx-5+sin(time()),wy)
   end
   wy+=6
  end
  clip()
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  end
 end
end

function addwind(_x,_y,_w,_h,_txt)
 local w={
  x=_x,
  y=_y,
  w=_w,
  h=_h,
  txt=_txt
 }
 add(wind,w)
 return w
end

function rectfill2(_x,_y,_w,_h,_c)
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

--speako8_lib_min by bikibird
do d=split("aa=1320,1,500,4,2,0,1,2600,160,1220,70,700,130,-250,100;ae=1270,1,1000,4,2,0,.79,2430,320,1660,150,620,170,-250,100;ah=770,1,1000,4,2,0,.79,2550,140,1220,50,620,80,-250,100;ao=1320,1,1000,4,2,0,.74,2570,80,990,100,600,90,-250,100;aw=720,1,1000,4,2,0,.79,2550,140,1230,70,640,80,-250,100/720,1,1000,4,3,0,0,2350,80,940,70,420,80,-250,100;ay=690,1,1000,4,2,0,.9,2550,200,1200,70,660,100,-250,100/690,1,1000,4,2,0,.223,2550,200,1880,100,400,70,-250,100;eh=830,1,1000,4,2,0,.44,2520,200,1720,100,480,70,-250,100;er=990,1,1000,4,2,0,.41,1540,110,1270,60,470,100,-250,100;ey=520,1,500,4,2,0,.44,2520,200,1720,100,480,70,-250,100/520,1,500,4,2,0,.05,2600,200,2020,100,330,50,-250,100;ih=720,1,1000,4,2,0,.23,2570,140,1800,100,400,50,-250,100;iy=880,1,1000,4,2,0,0,2960,400,2020,100,310,70,-250,100;ow=1210,1,1000,4,2,0,.59,2300,70,1100,70,540,80,-250,100;oy=513,1,1000,4,2,0,.62,2400,130,960,50,550,60,-250,100/513,1,1000,4,2,0,.13,2400,130,1820,50,360,80,-250,100/513,1,1000,4,2,0,.13,2400,130,1820,50,360,80,-250,100;uh=880,1,1000,4,2,0,.36,2350,80,1100,100,450,80,-250,100;uw=390,1,1000,4,2,0,.1,2200,140,1250,110,350,70,-250,100/390,1,1000,0,1,0,-.12,2200,140,900,110,320,70,-250,100/390,1,1000,0,0,0,-.12,2200,140,900,110,320,70,-250,100;l=440,1,1000,0,2,0,0,2880,280,1050,100,310,50,-250,100;r=440,1,1000,0,2,0,0,1380,120,1060,100,310,70,-250,100;m=390,1,1000,0,0,0,0,2150,200,1100,150,400,300,-450,100;n=360,1,1000,0,0,0,0,2600,170,1600,100,200,60,-450,100;ng=440,1,1000,0,0,0,0,2850,280,1990,150,200,60,-450,100;ch=230,0,20,0,0,1,0,2820,300,1800,90,350,200,-250,100/100,0,100,1,0,1,0,2820,300,1800,90,350,200,-250,100;sh=690,0,20,0,0,1,0,2750,300,1840,100,300,200,-250,100;zh=1,1,250,0,0,.5,0,2750,300,1840,100,300,200,-250,100/385,1,400,1,0,.5,0,2750,300,1840,100,300,200,-250,100;jh=330,1,500,1,0,1,0,2820,270,1800,80,260,60,-250,100;dh=275,1,250,0,0,.5,0,2540,170,1290,80,270,60,-250,100;f=1,0,15,0,0,1,0,2080,150,1100,120,340,200,-250,100/660,0,25,1,0,1,0,2080,150,1100,120,340,200,-250,100;s=690,0,10,0,0,1,0,2530,200,1390,80,320,200,-250,100;k=88,0,100,0,0,1,0,2850,330,1900,160,300,250,-250,100/220,2,5,1,0,1,0,2850,330,1900,160,300,250,-250,100;p=44,0,50,0,0,1,0,2150,220,1100,150,400,300,-250,100/220,2,2,1,0,1,0,2150,220,1100,150,400,300,-250,100;t=66,0,100,0,0,2,0,2600,250,1600,120,400,300,-250,100/220,2,5,0,0,1,0,2600,250,1600,120,400,300,-250,100;g=88,0,100,0,0,1,0,2850,280,1990,150,200,60,-250,100;b=44,0,100,0,1,0,0,2150,220,1100,150,400,300,-250,100;d=66,0,100,0,0,1,0,2600,170,1600,100,200,60,-250,100;th=606,0,10,0,0,1,0,2540,200,1290,90,320,200,-250,100;v=330,1,1000,0,0,.5,0,2080,120,1100,90,220,60,-250,100;z=410,1,1000,0,0,.5,0,2530,180,1390,60,240,70,-250,100;w=440,1,1000,0,0,0,.1,2150,60,610,80,290,50,-250,100;y=440,1,1000,0,0,0,0,3020,500,2070,250,260,40,-250,100;",";")x={}for a in all(d)do local e=split(a,"=")local d,a=e[1],split(e[2],"/")x[d]={}for e in all(a)do local a=split(e)local e={unpack(a,1,7)}e[8]={}for x=8,14,2do add(e[8],{unpack(a,x,x+1)})end add(x[d],e)end end poke(24374,@24374^^32)local C,y,D,g,z,E,d,r,n,b,m,F,s,u,j,G,H,I,o,f,l=unpack(split"0,0,0,0,0,0,0,0,0,0,0x8000,0x1.233b,-0x.52d4")local c,w,i,h,J,K,k,t,p,v,q,A,B={}e=split"2,0x1.fd17,0x1.fa32,0x1.f752,0x1.f475,0x1.f19d,0x1.eec9,0x1.ebfa,0x1.e92e,0x1.e666,0x1.e3a3,0x1.e0e3,0x1.de27,0x1.db70,0x1.d8bc,0x1.d60c,0x1.d360,0x1.d0b9,0x1.ce14,0x1.cb74,0x1.c8d8,0x1.c63f,0x1.c3aa,0x1.c119,0x1.be8c,0x1.bc02,0x1.b97c,0x1.b6fa,0x1.b47b,0x1.b200,0x1.af89,0x1.ad15,0x1.aaa5,0x1.a838,0x1.a5cf,0x1.a369,0x1.a107,0x1.9ea9,0x1.9c4d,0x1.99f6,0x1.97a1,0x1.9550,0x1.9302,0x1.90b8,0x1.8e71,0x1.8c2e,0x1.89ed,0x1.87b0,0x1.8576,0x1.8340,0x1.810c,0x1.7edc,0x1.7caf,0x1.7a85,0x1.785f,0x1.763b,0x1.741b,0x1.71fd,0x1.6fe3,0x1.6dcc,0x1.6bb8,0x1.69a7,0x1.6798,0x1.658d,0x1.6385,0x1.6180,0x1.5f7e,0x1.5d7e,0x1.5b82,0x1.5988,0x1.5792,0x1.559e,0x1.53ad,0x1.51bf,0x1.4fd3,0x1.4deb,0x1.4c05,0x1.4a22,0x1.4842,0x1.4664,0x1.4489,0x1.42b1,0x1.40dc,0x1.3f09,0x1.3d39,0x1.3b6b,0x1.39a0,0x1.37d8,0x1.3612,0x1.344f,0x1.328f,0x1.30d1,0x1.2f15,0x1.2d5c,0x1.2ba6,0x1.29f2,0x1.2841,0x1.2692,0x1.24e5,0x1.233b,0x1.2193,0x1.1fee,0x1.1e4b,0x1.1cab,0x1.1b0c,0x1.1971,0x1.17d7,0x1.1640,0x1.14ab,0x1.1319,0x1.1189,0x1.0ffb,0x1.0e6f,0x1.0ce5,0x1.0b5e,0x1.09d9,0x1.0857,0x1.06d6,0x1.0558,0x1.03db,0x1.0261,0x1.00e9,0x.ff74,0x.fe00,0x.fc8f,0x.fb1f,0x.f9b2,0x.f847,0x.f6dd,0x.f576,0x.f411,0x.f2ae,0x.f14d,0x.efee,0x.ee91,0x.ed36,0x.ebdd,0x.ea86,0x.e930,0x.e7dd,0x.e68c,0x.e53c,0x.e3ef,0x.e2a3,0x.e15a,0x.e012,0x.decc,0x.dd88,0x.dc45,0x.db05,0x.d9c6,0x.d889,0x.d74e,0x.d615,0x.d4de,0x.d3a8,0x.d274,0x.d142,0x.d012,0x.cee3,0x.cdb6,0x.cc8b,0x.cb61,0x.ca39,0x.c913,0x.c7ee,0x.c6cc,0x.c5aa,0x.c48b,0x.c36d,0x.c251,0x.c136,0x.c01d,0x.bf05,0x.bdef,0x.bcdb,0x.bbc8,0x.bab7,0x.b9a7,0x.b899,0x.b78d,0x.b682,0x.b578,0x.b470,0x.b36a,0x.b265,0x.b161,0x.b05f,0x.af5f,0x.ae5f,0x.ad62,0x.ac66,0x.ab6b,0x.aa71,0x.a979,0x.a883,0x.a78e,0x.a69a,0x.a5a8,0x.a4b7,0x.a3c7,0x.a2d9,0x.a1ec,0x.a100,0x.a016,0x.9f2d,0x.9e45,0x.9d5f,0x.9c7a,0x.9b97,0x.9ab4,0x.99d3,0x.98f3,0x.9815,0x.9738,0x.965c,0x.9581,0x.94a7,0x.93cf,0x.92f8,0x.9222,0x.914e,0x.907a,0x.8fa8,0x.8ed7,0x.8e07,0x.8d39,0x.8c6b,0x.8b9f,0x.8ad4,0x.8a0a,0x.8941,0x.8879,0x.87b3,0x.86ed,0x.8629,0x.8566,0x.84a4,0x.83e3,0x.8323,0x.8264,0x.81a7,0x.80ea,0x.802e,0x.7f74,0x.7eba,0x.7e02,0x.7d4b,0x.7c94,0x.7bdf,0x.7b2b,0x.7a78,0x.79c6,0x.7915,0x.7864,0x.77b5,0x.7707,0x.765a,0x.75ae,0x.7503,0x.7458,0x.73af,0x.7307,0x.725f,0x.71b9,0x.7114,0x.706f,0x.6fcb,0x.6f29,0x.6e87,0x.6de6,0x.6d46,0x.6ca7,0x.6c09,0x.6b6c,0x.6ad0,0x.6a35"a=split"1,0x.fd19,0x.fa3a,0x.f764,0x.f497,0x.f1d1,0x.ef13,0x.ec5e,0x.e9b0,0x.e70a,0x.e46c,0x.e1d5,0x.df46,0x.dcbe,0x.da3d,0x.d7c4,0x.d552,0x.d2e7,0x.d083,0x.ce26,0x.cbd0,0x.c981,0x.c738,0x.c4f6,0x.c2bb,0x.c086,0x.be57,0x.bc2f,0x.ba0d,0x.b7f1,0x.b5dc,0x.b3cc,0x.b1c2,0x.afbf,0x.adc1,0x.abc9,0x.a9d6,0x.a7e9,0x.a602,0x.a421,0x.a244,0x.a06e,0x.9e9c,0x.9cd0,0x.9b09,0x.9947,0x.978a,0x.95d3,0x.9420,0x.9272,0x.90c9,0x.8f25,0x.8d86,0x.8beb,0x.8a55,0x.88c4,0x.8737,0x.85af,0x.842b,0x.82ac,0x.8130,0x.7fba,0x.7e47,0x.7cd9,0x.7b6e,0x.7a08,0x.78a6,0x.7748,0x.75ee,0x.7498,0x.7346,0x.71f7,0x.70ad,0x.6f66,0x.6e22,0x.6ce3,0x.6ba7,0x.6a6f,0x.693a,0x.6809,0x.66db,0x.65b0,0x.6489,0x.6366,0x.6245,0x.6128,0x.600e,0x.5ef7,0x.5de4,0x.5cd3,0x.5bc6,0x.5abc,0x.59b5,0x.58b0,0x.57af,0x.56b1,0x.55b5,0x.54bc,0x.53c7,0x.52d4,0x.51e3,0x.50f6,0x.500b,0x.4f22,0x.4e3d,0x.4d5a,0x.4c79,0x.4b9c,0x.4ac0,0x.49e7,0x.4911,0x.483d,0x.476b,0x.469c,0x.45cf,0x.4505,0x.443c,0x.4376,0x.42b3,0x.41f1,0x.4132,0x.4075,0x.3fba,0x.3f01,0x.3e4a,0x.3d95,0x.3ce3,0x.3c32,0x.3b83,0x.3ad7,0x.3a2c,0x.3983,0x.38dc,0x.3837,0x.3794,0x.36f3,0x.3653,0x.35b6,0x.351a,0x.3480,0x.33e8,0x.3351,0x.32bc,0x.3229,0x.3197,0x.3107,0x.3079,0x.2fed,0x.2f62,0x.2ed8,0x.2e50,0x.2dca,0x.2d45,0x.2cc2,0x.2c40,0x.2bbf,0x.2b40,0x.2ac3,0x.2a47,0x.29cc,0x.2953,0x.28db,0x.2864,0x.27ef,0x.277b,0x.2709,0x.2698,0x.2628,0x.25b9,0x.254b,0x.24df,0x.2474,0x.240a,0x.23a2,0x.233b,0x.22d4,0x.226f,0x.220b,0x.21a9,0x.2147,0x.20e6,0x.2087,0x.2029,0x.1fcb,0x.1f6f,0x.1f14,0x.1eba,0x.1e60,0x.1e08,0x.1db1,0x.1d5b,0x.1d06,0x.1cb2,0x.1c5e,0x.1c0c,0x.1bbb,0x.1b6a,0x.1b1b,0x.1acc,0x.1a7e,0x.1a31,0x.19e5,0x.199a,0x.1950,0x.1907,0x.18be,0x.1876,0x.182f,0x.17e9,0x.17a4,0x.175f,0x.171b,0x.16d8,0x.1696,0x.df50,0x.1614,0x.15d3,0x.1594,0x.1556,0x.1518,0x.14da,0x.149e,0x.cbd9,0x.1427,0x.13ec,0x.13b3,0x.137a,0x.1341,0x.1309,0x.12d2,0x.ba15,0x.1265,0x.1230,0x.11fb,0x.11c7,0x.1193,0x.1160,0x.112e,0x.a9de,0x.10cb,0x.109a,0x.106a,0x.103a,0x.100b,0x.0fdd,0x.0faf,0x.9b10,0x.0f54,0x.0f28,0x.0efc,0x.0ed0,0x.0ea5,0x.0e7b,0x.0e51,0x.8d8c,0x.0dfe,0x.0dd6,0x.0dad,0x.0d86,0x.0d5e,0x.0d38,0x.0d11,0x.8136,0x.0cc6,0x.0ca1,0x.0c7c,0x.0c58,0x.0c34,0x.0c11,0x.0bee,0x.0bcb,0x.0ba9,0x.0b87,0x.0b66,0x.0b45,0x.0b24,0x.0b03"function say(e)local p=split(e,"/")local d,e,a,n,t,f,m,j,r,v={},{}local s,b,u,w,y,g=unpack(split"1,1,0,0,0,0")for z in all(p)do local p=tonum(z)if p then local a=abs(p)local e,d,x=sgn(p),a\1,a&.99999
    if(d==1)b=1+e*x
    if(d==2)s=1+e*x
    if d==3then u=e
    if(x>0)u*=x
    end elseif z=="hh"then g=b*440elseif z=="_"then add(c,{1100*b*spk8_rate})else for p in all(x[z])do f,o,m,j,r,i,h,k=unpack(p)a,n,t,v,d,w,e,y={},{},{},f*b,e,y,k,m l=u*spk8_intonation+h*spk8_if0
    if(j==0)w=m
    if(r==0or#d~=#e)d=k
    for c=1,#d do add(a,{unpack(d[c])})local x,d=a[c],e[c]local e,a=r*(d[1]-x[1]),r*(d[2]-x[2])x.x,x.e,x.d=0,0,0if c<4then e*=spk8_shift a*=spk8_bandwidth end add(n,e/f)add(t,a/f)end if g>0then add(c,{g,2,0,1,0,1,h,a,n,t,e,s,l})g=0end add(c,{v,o,i,w,j*(y-w)/f,y,h,a,n,t,e,s,l})end s,b,u=1,1,0end end end function speaking()return#c>0end function mute()c={}b=0end function speako8()local function x()f=(5512.5/(spk8_pitch+l)+(f and f*49or 0))/(f and 50or 1)end if#c>0then w=c[1]while stat(108)<1920do for k=0,127do if w then if b<1then b,o,i,u,j,G,h,J,H,I,K,B,l=unpack(w)b/=spk8_rate end if o then x()t,d,p=spk8_quality*f,u/8,o*spk8_whisper if p==1then if n%flr(f+.5)==0then r,q,n=-d/(f-1),-d/t/t,0v=-q*t/3x()end if n>t then r=-d/(f-1)else v+=q r-=v end d=r elseif p>1then d=-8for x=1,16do d+=rnd()end
    if(n>f\2)d/=2
    end for n,x in pairs(J)do local b,c,f,o=x[1],x[2]\10+1c=c<=#e and c or#e c=c>=1and c or 1A=cos(b/5512.5)if b>0then f,o=e[c]*A,-a[c]x.d,x.e,x.x=x.e,x.x x.x=(1-f-o)*d+f*x.e+o*x.d d=x.x elseif b<0then f=F*A local x=1-f-s C=(d-f*y-s*D)/x D,y,f=y,d,F*cos(.04897)g=(1-f-s)*C+f*z+s*E E,z=z,g d=g end local e=K[n]
    if(b\10~=e[1]\10)x[1]+=H[n]
    if(c-1~=e[2]\10)x[2]+=I[n]
    end d*=i/2-1+rnd(i)
    if(abs(u-G)>abs(j))u+=j
    else d,B=0,1end n+=1b-=1poke(m+k,d*spk8_volume*B+128)if b<1then deli(c,1)if#c==0then serial(2056,m,k+1)return else w=c[1]end end end end serial(2056,m,128)end end end end
--declare: https://bikibird.itch.io/declare
--end of speako8_lib_min
__gfx__
00000000000000000000000000000000000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000600006006555560000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000006000000665555556000000000000000000000000000000000000000000000000000000000000000000000000
000770000008800000099000000bb0000000000060000006655555560000000000000000000aa000000000000000000000000000000000000000000000000000
00077000008888000099990000b44b00000880006000000665555556000000000009900000a99a00000000000000000000000000000000000000000000000000
0070070000899800099aa9900b4aa4b0008228000600006006555560000aa000009aa9000a9aa9a0000000000000000000000000000000000000000000000000
000000000889988099aaaa990baaaab0022aa220006006000065560000a00a0009a00a90a9a00a9a000000000000000000000000000000000000000000000000
0000000088888888999aa99900baab002222222200066000000660000a0000a09a0000a99a0000a9000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066660000066660000066660000
00077007700770777077700000000077700000000000000000000000000070707770707077700000000077000000000000000655556000655556000655556000
00700070007070707070000700000070700000000000000000000000000070707070707070000700000007000000000000006555555606555555606555555600
00777070007070770077000000000070700000000000000000000000000070707770707077000000000007000000000000006555555606555555606555555600
00007070007070707070000700000070700000000000000000000000000077707070777070000700000007000000000000006555555606555555606555555600
00770007707700707077700000000077700000000000000000000000000d77707070070077700000000077700000000000000655556d00655556000655556000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065560000065560000065560000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000006600000006600000006600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000600000000000000000000
00000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000990000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099aa9900000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099aaaa990000000000000000000000000000
00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000999aa99900000000000000000000000000d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000bb00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000b44b0d000000000000bb000000000000000000000000000000000000000
000000000000000000000000000000000000000bb000000000000000000000000000b4aa4b00000000bb00b44b0000000000000000bb0000000000bb00000000
00000000000000000000000000000000000000b44b00000000000000000000000000baaaab0000000b44bb4aa4b00000000000000b44b00000000b44b0000000
0000000000000000000000000000000000000b4aa4b00000000000000000000000000baab0000000b4aa4baaaab0000000000000b4aa4b000000b4aa4b000000
0000000000000000000000000000000000000baaaab000000000000000000000000000000000000bbaaaabbaab00000000000000baaaab000000baaaab000000
00000000000000000000000000000000000000baab000000000000000000000000000000000000b4abaab00000000000000000000baab00000000baab0000000
00000600000000000000d000000000000000000000000000000000000000000000000000000000baaaab00000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000baab060000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000600000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000
000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000
0000000000000000000000a99a000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000a9aa9a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a9a00a9a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000009a0000a90000000000000000000010000000000000000000000600000000000000000000000000000000000000000000000000000000
00000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000008998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000088998800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000
000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000341202d1002f13023100241501610018140291000d1302310004120000001a10000000000001210000000091000000003100000000000000000000000000000000000000000000000000000000000000
001000000061004630046500a6500465007650046300162000000000000260004600086000e600000000b60001600000000b6001160007600016000b600000000260000000000000000000000000000000000000
00100000186500e650086500000003650000000065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e3202d1002e33023100233501610018140291000d1302310004120000001a10000000000001210000000091000000003100000000000000000000000000000000000000000000000000000000000000
000e0000066200163011650046500b67001630066500c650046300162000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
