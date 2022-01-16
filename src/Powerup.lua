

Powerup = Class{}

function Powerup:init(x, y, type)
    self.type = type
    self.x = x
    self.y = y
    self.dy = 15
    self.size = 16
    self.inPlay = true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
    if self.type == 10 then
        self.y = math.min(self.y, VIRTUAL_HEIGHT - 32)
    end
end

function Powerup:collides(paddle)
    if self.inPlay then
        if (paddle.x > self.x+self.size    or
            paddle.x+paddle.width < self.x or
            paddle.y > self.y+self.size    or
            paddle.y+paddle.height < self.y) then
            return false
        else
            return true
        end
    end
end

function Powerup:render(type)
    if self.inPlay then
        love.graphics.draw(gTextures['main'], 
            gFrames['powerups'][self.type], self.x, self.y)
    end
end