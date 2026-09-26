class Car
    attr_reader :z
    
    def self.models
        @models ||= {
            yellow: Model3D.new('gfx/models/car.obj')
        }
    end

    def self.texture
        @texture ||= GLTexture.new('gfx/funkyfuture-8-8x.png')
    end

    def initialize(angle = 90, z = 0)
        @angle, @z = angle, z
        @x = (@angle == 90) ? -1 : 1
        @y = 0
        @speed = 10.0
        @type = Car.models.keys.sample 
    end

    def update(dt)
        @x += @speed * dt * Math.cos(@angle * Math::PI / 180.0)
        @z += @speed * dt * Math.sin(@angle * Math::PI / 180.0)
    end

    def draw
        glPushMatrix
            glTranslatef(@x, @y, @z)
            glRotatef(@angle - 90, 0, 1, 0)
            Car.models[@type].draw(Car.texture)
        glPopMatrix
    end
end