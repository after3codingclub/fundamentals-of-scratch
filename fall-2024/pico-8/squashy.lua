music (0,1)
-- ball 
ballx=64 
bally=64 
ballsize=3 
ballxdir=5 
ballydir=-3
-- paddle 
padx=52 
pady=122 
padw=24 
padh=4
--score
score=0
--lives
lives=3

function moveball() 
ballx+=ballxdir 
bally+=ballydir
end

function movepaddle() 
if btn (0) then
padx-=3
elseif btn(1) then
padx+=3 
end
end

function bounceball() 
-- left
if ballx < ballsize then 
ballxdir=-ballxdir
sfx(0) 
end
-- right
if ballx > 128-ballsize then 
ballxdir=-ballxdir
sfx(0) 
end
-- top
if bally < ballsize then
ballydir=-ballydir
sfx(0) 
end
end

-- bounce the ball off the paddle 
function bouncepaddle()
if ballx>=padx and 
ballx<=padx+padw and 
bally>pady then
sfx(1)
score+=10 -- increase the score on a hit!
ballydir=-ballydir
end
end

function losedeadball() 
if bally>128-ballsize then
if lives>0 then 
-- next life 
sfx(2) 
bally=24 
lives-=1
else
-- game over 
sfx(3)
ballydir=0 
ballxdir=0 
bally=64
lives-=1
end 
end
end

function _update() 
moveball()
movepaddle()
bounceball()
bouncepaddle()
losedeadball()
end

function _draw()
-- clear the screen
cls() 
rectfill(0,0, 128,128, 3)
-- draw the lives
for i=1,lives do
spr(000, 90+i*8, 4)
end
--status
if lives>=0 then
else
print ("you lose",50,50,15)
end
-- draw the score
print(score, 12, 6, 15)
-- draw the paddle
rectfill(padx,pady, padx+padw,pady+padh, 15) 
-- draw the ball
circfill(ballx,bally,ballsize,15)
end
