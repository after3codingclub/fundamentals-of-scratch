-- simple top-down driving game with scrolling road and oncoming traffic

-- player variables
player = {
  x = 64,
  y = 64,
  speed = 2
}

-- road variables
road = {
  y = 0,
  speed = 2
}

-- obstacles variables
obstacles = {}

function _init()
  -- initialize game state
  for i = 1, 5 do
    createobstacle()
  end
end

function _update()
  -- update game logic

  -- move the player
  if btn(0) then player.x = player.x - player.speed end
  if btn(1) then player.x = player.x + player.speed end
  if btn(2) then player.y = player.y - player.speed end
  if btn(3) then player.y = player.y + player.speed end

  -- move the road
  road.y = road.y + road.speed
  if road.y > 128 then
    road.y = 0
  end

  -- move obstacles
  for i, obstacle in pairs(obstacles) do
    obstacle.y = obstacle.y + road.speed + obstacle.speed
    if obstacle.y > 128 then
      obstacles[i].y = rnd(128)
    end

    -- check for collision with player
    if checkcollision(player, obstacle) then
      -- handle collision (you can add game over logic here)
      player.x = 64
      player.y = 64
    end
  end
end

function _draw()
  -- draw game elements

  -- clear the screen
  cls()

  -- draw road
  rectfill(0, road.y, 128, road.y + 16, 7)

  -- draw player car
  spr(1, player.x, player.y)

  -- draw obstacles
  for _, obstacle in pairs(obstacles) do
    spr(2, obstacle.x, obstacle.y)
  end
end

function createobstacle()
  -- check if the number of obstacles is less than 20 before creating a new one
  if #obstacles < 20 then
    local obstacle = {
      x = rnd(128),
      y = rnd(128),
      speed = rnd(2) + 1
    }
    add(obstacles, obstacle)
  end
end

function checkcollision(obj1, obj2)
  return obj1.x < obj2.x + 8 and obj1.x + 8 > obj2.x and obj1.y < obj2.y + 8 and obj1.y + 8 > obj2.y
end
