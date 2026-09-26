class Car
    attr_reader :z, :angle

    def self.models
        @models ||= {
            green: Model3D.new('gfx/models/car.obj', [-0.4, 0.8, -0.45]),
            blue: Model3D.new('gfx/models/car2.obj', [-0.4, 0.8, -0.45]),
            yellow: Model3D.new('gfx/models/car3.obj', [-0.4, 0.8, -0.45])
        }
    end

    def self.texture
        @texture ||= GLTexture.new('gfx/lospec500-8x.png')
    end

    def initialize(angle = 90, z = 0)
        @angle, @z = angle, z
        @lane_x = (@angle == 90) ? -2.1 : 2.1
        @x = @lane_x
        @y = 0
        @speed = 10.0
        @type = Car.models.keys.sample 

        # we want the driver not to be so precise
        @wobble_amp = [0, Gosu.random(0.8, 1.1)].sample # 1 chance out of 2 to stand still
        @wobble_freq = Gosu.random(0.25, 0.4) # per second
        @wobble_phase = Gosu.random(0, 2 * Math::PI) # we don't want it to be sync between all cars
        @time = 0
    end

    def update(dt)
        @time += dt
        wave = 2 * Math::PI * @wobble_freq * @time + @wobble_phase
        @x = @lane_x + @wobble_amp * Math.sin(wave)
        @vx = @wobble_amp * 2 * Math::PI * @wobble_freq * Math.cos(wave)
        @vz = @speed * Math.sin(@angle * Math::PI / 180.0)
        @z += @vz * dt
    end

    def draw
        glPushMatrix
            glTranslatef(@x, @y, @z)
            base = (@vz || 1) >= 0 ? 0 : 180
            wobble = Math.atan2(@vx || 0, (@vz || 1).abs) * 180 / Math::PI
            wobble = -wobble if base == 180
            glRotatef(base + wobble * 1.5, 0, 1, 0)
            Car.models[@type].draw(Car.texture)
        glPopMatrix
    end
end