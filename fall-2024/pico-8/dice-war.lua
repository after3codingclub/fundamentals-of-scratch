-- MMORPG DICE GAME
-- BY CHATGPT
-- FREE-FOR-ALL MODE

-- CONSTANTS
outcomes = {"ambush", "down", "run", "fire", "rally", "advance"}
outcome_colors = {8, 9, 10, 11, 12, 7} -- Colors for each outcome

-- GAME STATE
players = {}
zones = {"safe", "combat", "resource"}
zone_colors = {6, 2, 14}
turn_timer = 0
max_turn_time = 30 -- Time for each round (in frames)

-- INIT FUNCTION
function _init()
  -- Initialize players
  for i = 1, 12 do
    add(players, {
      id = i,
      zone = flr(rnd(3)) + 1, -- Random starting zone
      dice = {roll_dice(), roll_dice()},
      hp = 3, -- Hit points
      score = 0,
    })
  end
end

-- MAIN UPDATE FUNCTION
function _update()
  -- Countdown to next turn
  turn_timer += 1
  if turn_timer >= max_turn_time then
    resolve_round()
    turn_timer = 0
  end
end

-- MAIN DRAW FUNCTION
function _draw()
  cls() -- Clear screen

  -- Draw zones
  for i = 1, #zones do
    rectfill(0, (i - 1) * 40, 127, i * 40 - 1, zone_colors[i])
    print(zones[i], 2, (i - 1) * 40 + 2, 7)
  end

  -- Draw players
  for player in all(players) do
    local x = 10 + (player.id - 1) % 6 * 20
    local y = (player.zone - 1) * 40 + 20
    circfill(x, y, 5, 7)
    print(player.hp, x - 2, y - 8, 8) -- HP
    for i, die in ipairs(player.dice) do
      print(outcomes[die], x - 16 + i * 16, y + 8, outcome_colors[die])
    end
  end

  -- Draw timer
  print("time: "..(max_turn_time - turn_timer), 2, 2, 7)
end

-- RESOLVE A ROUND
function resolve_round()
  for player in all(players) do
    -- Apply dice effects
    for die in all(player.dice) do
      apply_outcome(player, die)
    end

    -- Roll new dice
    player.dice = {roll_dice(), roll_dice()}
  end

  -- Check for eliminations
  for player in all(players) do
    if player.hp <= 0 then
      del(players, player)
    end
  end

  -- Check for win condition
  if #players == 1 then
    print("player "..players[1].id.." wins!")
    poke(0x5f2d, 1) -- Pause game
  end
end

-- APPLY OUTCOME EFFECTS
function apply_outcome(player, die)
  if die == 1 then
    -- Ambush: damage random opponent in the same zone
    local target = random_target(player.zone, player)
    if target then
      target.hp -= 1
    end
  elseif die == 2 then
    -- Down: reduce opponent's dice
    local target = random_target(player.zone, player)
    if target then
      target.dice[1] = roll_dice()
    end
  elseif die == 3 then
    -- Run: move to a random zone
    player.zone = flr(rnd(3)) + 1
  elseif die == 4 then
    -- Fire: damage all opponents in the same zone
    for other in all(players) do
      if other.zone == player.zone and other != player then
        other.hp -= 1
      end
    end
  elseif die == 5 then
    -- Rally: heal self
    player.hp = min(player.hp + 1, 3)
  elseif die == 6 then
    -- Advance: score a point
    player.score += 1
  end
end

-- HELPER: ROLL A DIE
function roll_dice()
  return flr(rnd(6)) + 1
end

-- HELPER: FIND RANDOM TARGET IN ZONE
function random_target(zone, exclude_player)
  local targets = {}
  for other in all(players) do
    if other.zone == zone and other != exclude_player then
      add(targets, other)
    end
  end
  if #targets > 0 then
    return targets[flr(rnd(#targets)) + 1]
  end
  return nil
end