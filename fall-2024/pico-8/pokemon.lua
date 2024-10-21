-- pokemon clone in pico-8 with enhanced battle system

local player_x = 64
local player_y = 64

local enemy = {} -- single enemy
local max_enemy_hp = 20

local player_hp = 20
local player_max_hp = 20

local in_battle = false
local player_turn = true

local feedback_timer = 0
local feedback_duration = 60 -- 60 frames = 1 second
local battle_ended = false -- new flag to track if battle is over

function _init()
  -- set up your initial game state here
  resetgame()
end

function _update()
  if feedback_timer > 0 then
    feedback_timer -= 1
  elseif battle_ended then
    -- check for any keypress to reset the game after battle ends
    if btnp() then
      resetgame()
    end
  else
    if not in_battle then
      moveplayer()
      checkencounter()
    else
      if player_turn then
        playerturn()
      else
        enemyturn()
      end
    end
  end
end

function _draw()
  cls()

  if not in_battle then
    spr(1, player_x, player_y)
    if enemy.hp > 0 then
      spr(2, enemy.x, enemy.y) -- display the enemy sprite for reference
    end
  else
    print("player hp: " .. player_hp .. "/" .. player_max_hp, 10, 10, 7)
    print("enemy hp: " .. enemy.hp, 10, 20, 8)

    if player_turn then
      print("a: attack", 10, 120, 7)
    else
      print("enemy's turn", 10, 120, 8)
    end

    -- win/lose outcomes
    if player_hp <= 0 then
      print("you lose! press any key to return", 60, 60, 8)
      battle_ended = true
    elseif enemy.hp <= 0 then
      print("you win! press any key to return", 60, 60, 7)
      battle_ended = true
    end
  end

  -- display feedback for a certain duration
  if feedback_timer > 0 then
    feedback_timer -= 1
    if feedback_timer == 0 then
      resetgame()
    end
  end
end

function moveplayer()
  if btn(0) then player_x = player_x - 1 end -- left
  if btn(1) then player_x = player_x + 1 end -- right
  if btn(2) then player_y = player_y - 1 end -- up
  if btn(3) then player_y = player_y + 1 end -- down
end

function checkencounter()
  -- simple encounter logic, check if player is within a certain range of the enemy
  local encounter_range = 8
  if abs(player_x - enemy.x) < encounter_range and abs(player_y - enemy.y) < encounter_range and enemy.hp > 0 then
    in_battle = true
  end
end

function playerturn()
  -- player's turn logic
  if btn(4) then -- a button for "attack"
    local player_damage = flr(rnd(4)) + 1 -- random damage between 1 and 5
    enemy.hp = max(enemy.hp - player_damage, 0)
    player_turn = false -- switch to enemy's turn
  end
end

function enemyturn()
  -- enemy's turn logic
  if player_hp > 0 then
    local enemy_damage = flr(rnd(4)) + 1 -- random damage between 1 and 4
    player_hp = max(player_hp - enemy_damage, 0)
  end

  player_turn = true -- switch back to player's turn
end

function resetgame()
  -- reset game state after win or lose
  player_hp = player_max_hp
  in_battle = false
  player_turn = true
  player_x = 64
  player_y = 64

  enemy = { -- reset the enemy with random position and health
    x = rnd(120),
    y = rnd(100) + 20,
    hp = max_enemy_hp
  }

  feedback_timer = 0
  battle_ended = false -- reset the flag when the game is reset
end
