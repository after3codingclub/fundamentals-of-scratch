-- slot machine with spinning animation in pico-8

-- variables
reels = {1, 1, 1} -- current positions of the 3 reels
symbols = {"♥", "♦", "★", "♠", "☀", "☂"} -- symbols on the reels
spinning = {false, false, false} -- track if each reel is spinning
speed = {0, 0, 0} -- speed of each reel
money = 100 -- player's starting money
bet = 10 -- bet per spin
result_message = ""

-- initialize game
function _init()
    result_message = "press ❎ to spin!"
end

-- update game state
function _update()
    -- spin reels when button is pressed
    if btnp(5) and not spinning[1] and money >= bet then
        start_spin()
    end

    -- update spinning for each reel
    for i = 1, 3 do
        if spinning[i] then
            reels[i] = reels[i] + speed[i]
            if reels[i] > #symbols then
                reels[i] = 1 -- loop back to the first symbol
            elseif reels[i] < 1 then
                reels[i] = #symbols -- loop back to the last symbol
            end
            
            -- decelerate reel over time
            speed[i] = speed[i] * 0.95
            
            -- stop reel when it's slow enough
            if speed[i] < 0.1 then
                spinning[i] = false
                speed[i] = 0
            end
        end
    end

    -- if all reels stop, check the result
    if not spinning[1] and not spinning[2] and not spinning[3] and result_message == "" then
        check_win()
    end
end

-- start the spin
function start_spin()
    money -= bet -- deduct bet
    result_message = ""
    
    -- set initial speed for each reel and start spinning
    for i = 1, 3 do
        spinning[i] = true
        speed[i] = 5 + rnd(3) -- random initial speed
    end
end

-- check if player won
function check_win()
    if reels[1] == reels[2] and reels[2] == reels[3] then
        result_message = "you win!"
        money += bet * 5
    else
        result_message = "try again!"
    end
end

-- draw the game screen
function _draw()
    cls()
    
    -- draw reels with current symbols
    for i = 1, 3 do
        print(symbols[flr(reels[i])], 30 * i, 50, 7)
    end

    -- display player's money and result message
    print("money: $"..money, 10, 10, 11)
    print(result_message, 10, 80, 10)

    -- instruction if not spinning
    if not spinning[1] then
        print("press ❎ to spin", 10, 90, 6)
    end
end
