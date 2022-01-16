--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.powerups = params.powerups or {}
    self.recoverPoints = params.recoverPoints or 5000

    -- give ball random starting velocity
    self.ball[1].dx = math.random(-200, 200)
    self.ball[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for k, ball in ipairs(self.ball) do
        ball:update(dt)
    end
    for k, ball in ipairs(self.ball) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end
    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for k, ball in ipairs(self.ball) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                if not(brick.color == 6 and brick.tier == 1) then
                    self.score = self.score + math.floor(brick.tier * 200 + brick.color * 25, self.paddle.size)
                end
                -- trigger the brick's hit function, which removes it from play
                if self.paddle.buff >= 0 then
                        brick:hit()
                    if self.paddle.buff > 0 and brick.inPlay then
                        brick:hit()
                        self.paddle.buff = self.paddle.buff - 1
                    end
                else
                    self.paddle.buff = self.paddle.buff + 1
                end
                if brick.powerup > 0 and not brick.inPlay then
                    table.insert(self.powerups, Powerup(brick.x+8, brick.y, brick.powerup))
                end
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(self.recoverPoints + 100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:update(dt)
        end
        if powerup:collides(self.paddle) then
            powerup.inPlay = false
            gSounds['powerup']:play()
            if powerup.type == 1      then
                self.score = math.max(0, self.score - 1000)
            elseif powerup.type == 2  then
                self.score = self.score + 1000
            elseif powerup.type == 3  then
                self.health = math.max(1, self.health - 1)
            elseif powerup.type == 4  then
                self.paddle.dx = 0
                self.paddle.freeze = 3
            elseif powerup.type == 5  then
                self.paddle:increase()
            elseif powerup.type == 6  then
                self.paddle:decrease()
            elseif powerup.type == 7  then
                self.paddle.buff = self.paddle.buff - 5
            elseif powerup.type == 8  then
                self.paddle.buff = self.paddle.buff + 5
            elseif powerup.type == 9  then
                self:newBall()
                self:newBall()
            elseif powerup.type == 10 then
                self.paddle.key = true
 
                
            end
        end
    end
    -- if ball goes below bounds, revert to serve state and decrease health
    for k, ball in ipairs(self.ball) do
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.ball, k)
            if #self.ball == 0 then
                self.health = self.health - 1
                self.paddle:reset()
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        powerups = self.powerups,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt, self.paddle)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, ball in ipairs(self.ball) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:newBall()
    local ball = Ball(self.ball[1].skin)
    ball.x = VIRTUAL_WIDTH/2
    ball.y = VIRTUAL_HEIGHT/2
    ball.dx = math.random(-200, 200)
    ball.dy = math.random(-50, -60)
    table.insert(self.ball, ball)
end