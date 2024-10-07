-- Pokemon Battle Game in PICO-8 with Music and SFX

-- Constants
MAX_ROUNDS = 10

-- Create Pokémon function
function create_pokemon(name, attack, speed, health, defense)
    return {
        name = name,
        attack_power = attack,
        attack_speed = speed,
        max_health = health,
        health = health,
        defense = defense,
        attack_timer = 0 -- Timer for attack delay
    }
end

-- Variables for game state
player = {pokemon = nil}
opponent = {pokemon = nil}
round = 1
game_over = false

-- Define some Pokémon creatures
pokemons = {
    create_pokemon("Pikachu", 10, 1, 30, 5),
    create_pokemon("Charmander", 12, 2, 25, 4),
    create_pokemon("Bulbasaur", 8, 1.5, 40, 6)
}

-- Function for Pokémon attacks
function attack(attacker, defender)
    if attacker.attack_timer <= 0 then
        -- Calculate damage: attack power - defender defense
        local damage = max(0, attacker.attack_power - defender.defense)
        defender.health = max(0, defender.health - damage)
        attacker.attack_timer = attacker.attack_speed -- reset attack timer
        
        -- Play attack sound
        sfx(0) -- Play sound effect #0 for attack
    end
end

-- Function to update battle each turn
function update_battle()
    -- Reduce attack timers
    player.pokemon.attack_timer -= 1
    opponent.pokemon.attack_timer -= 1
    
    -- Player attacks opponent
    attack(player.pokemon, opponent.pokemon)

    -- Opponent attacks player
    attack(opponent.pokemon, player.pokemon)

    -- Check if someone lost the round
    if player.pokemon.health <= 0 or opponent.pokemon.health <= 0 then
        end_round()
    end
end

-- Handle round end and start a new round
function end_round()
    if opponent.pokemon.health <= 0 then
        -- Player wins, can choose to take the opponent's Pokémon
        print("You won! Press Z to steal their Pokémon")
        -- Play win sound
        sfx(1) -- Play sound effect #1 for winning
        if btnp(4) then -- Button Z pressed
            player.pokemon = opponent.pokemon
        end
    else
        print("You lost the round!")
        -- Play lose sound
        sfx(2) -- Play sound effect #2 for losing
    end
    start_new_round()
end

-- Start a new round
function start_new_round()
    if round > MAX_ROUNDS then
        game_over = true
        return
    end

    -- Set new opponent Pokémon
    opponent.pokemon = create_pokemon("Random Enemy", rnd(10) + 10, rnd(2) + 1, rnd(30) + 20, rnd(5) + 3)
    
    -- Reset health for player and opponent
    player.pokemon.health = player.pokemon.max_health
    opponent.pokemon.health = opponent.pokemon.max_health
    
    round += 1
end

-- Initialize game state
function _init()
    player.pokemon = pokemons[1] -- Start with Pikachu
    start_new_round()
    
    -- Play background music
    music(0) -- Play music track #0 in a loop
end

-- Update game loop
function _update()
    if game_over then
        if btnp(4) then -- Press any key to restart
            _init()
        end
        return
    end

    -- Update battle between rounds
    update_battle()
end

-- Draw game graphics
function _draw()
    cls()
    
    -- Draw player's Pokémon stats
    print("Player: "..player.pokemon.name, 10, 10)
    print("Health: "..player.pokemon.health, 10, 20)
    
    -- Draw opponent's Pokémon stats
    print("Opponent: "..opponent.pokemon.name, 90, 10)
    print("Health: "..opponent.pokemon.health, 90, 20)

    -- Draw sprites for Pokémon (simple placeholder, customize sprite numbers)
    spr(1, 10, 40) -- Player Pokémon sprite
    spr(2, 90, 40) -- Opponent Pokémon sprite
    
    -- Game over screen
    if game_over then
        print("Game Over! Press any key to restart", 40, 80)
    end
end
