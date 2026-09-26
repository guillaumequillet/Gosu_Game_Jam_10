class Scooter
    def initialize(x = 0, y = 0, z = 0)
        @x, @y, @z = x, y, z
        @model = Model3D.new('gfx/models/scooter.obj')
        @texture = GLTexture.new('gfx/funkyfuture-8-8x.png')
    end

    def update(dt)

    end

    def draw
        @model.draw(@texture, @x, @y, @z)
    end
end