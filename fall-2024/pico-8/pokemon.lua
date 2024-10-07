-- Pokemon Clone in Pico-8 with Enhanced Battle System

local player_x = 64
local player_y = 64

local enemy = {} -- Single enemy
local max_enemy_hp = 15

local player_hp = 20
local player_max_hp = 20

local in_battle = false
local player_turn = true

local feedback_timer = 0
local feedback_duration = 60 -- 60 frames = 1 second

function _init()
  -- Set up your initial game state here
  resetGame()
end

function _update()
  if feedback_timer > 0 then
    feedback_timer -= 1
  else
    if not in_battle then
      movePlayer()
      checkEncounter()
    else
      if player_turn then
        playerTurn()
      else
        enemyTurn()
      end
    end
  end
end

function _draw()
  cls()

  if not in_battle then
    spr(1, player_x, player_y)
    if enemy.hp > 0 then
      spr(2, enemy.x, enemy.y) -- Display the enemy sprite for reference
    end
  else
    print("Player HP: " .. player_hp .. "/" .. player_max_hp, 10, 10, 7)
    print("Enemy HP: " .. enemy.hp, 10, 20, 8)

    if player_turn then
      print("A: Attack", 10, 120, 7)
    else
      print("Enemy's Turn", 10, 120, 8)
    end

    -- Win/Lose outcomes
    if player_hp <= 0 then
      print("You lose!", 60, 60, 8)
      feedback_timer = feedback_duration
    elseif enemy.hp <= 0 then
      print("You win!", 60, 60, 7)
      feedback_timer = feedback_duration
    end
  end

  -- Display feedback for a certain duration
  if feedback_timer > 0 then
    feedback_timer -= 1
    if feedback_timer == 0 then
      resetGame()
    end
  end
end

function movePlayer()
  if btn(0) then player_x = player_x - 1 end -- Left
  if btn(1) then player_x = player_x + 1 end -- Right
  if btn(2) then player_y = player_y - 1 end -- Up
  if btn(3) then player_y = player_y + 1 end -- Down
end

function checkEncounter()
  -- Simple encounter logic, check if player is within a certain range of the enemy
  local encounter_range = 8
  if abs(player_x - enemy.x) < encounter_range and abs(player_y - enemy.y) < encounter_range and enemy.hp > 0 then
    in_battle = true
  end
end

function playerTurn()
  -- Player's turn logic
  if btn(4) then -- A button for "Attack"
    local player_damage = flr(rnd(5)) + 1 -- Random damage between 1 and 5
    enemy.hp = max(enemy.hp - player_damage, 0)
    player_turn = false -- Switch to enemy's turn
  end
end

function enemyTurn()
  -- Enemy's turn logic
  if player_hp > 0 then
    local enemy_damage = flr(rnd(4)) + 1 -- Random damage between 1 and 4
    player_hp = max(player_hp - enemy_damage, 0)
  end

  player_turn = true -- Switch back to player's turn
end

function resetGame()
  -- Reset game state after win or lose
  player_hp = player_max_hp
  in_battle = false
  player_turn = true
  player_x = 64
  player_y = 64

  enemy = { -- Reset the enemy with random position and health
    x = rnd(120),
    y = rnd(100) + 20,
    hp = max_enemy_hp
  }

  feedback_timer = 0
end
