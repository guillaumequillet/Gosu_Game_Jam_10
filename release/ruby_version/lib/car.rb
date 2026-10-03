class Car
    attr_reader :z, :angle

    CIRCLE_RADIUS = 0.8
    CIRCLE_OFFSETS = [-1.0, 0.0, 1.0] # 3 circles along the car length

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
        @lane_x = (@angle == 90) ? -2.0 : 2.0
        @x = @lane_x
        @y = 0
        @speed = 10.0
        @type = Car.models.keys.sample 

        # we want the driver not to be so precise
        @wobble_amp = [0, Gosu.random(0.8, 1.2), Gosu.random(0.8, 1.2)].sample # 2 chances out of 3 to wobble
        @wobble_freq = Gosu.random(0.25, 0.4) # per second
        @wobble_phase = Gosu.random(0, 2 * Math::PI) # we don't want it to be sync between all cars
        @time = 0
        @vanish_time = nil
    end

    def update(dt)
        @time += dt
        wave = 2 * Math::PI * @wobble_freq * @time + @wobble_phase
        @x = @lane_x + @wobble_amp * Math.sin(wave)
        @vx = @wobble_amp * 2 * Math::PI * @wobble_freq * Math.cos(wave)
        @vz = @speed * Math.sin(@angle * Math::PI / 180.0)
        @z += @vz * dt
        @vanish_time += dt if vanishing?
    end

    def vanish!
        @vanish_time = 0
    end

    def vanishing?
        !@vanish_time.nil?
    end

    def vanished?
        vanishing? && @vanish_time > 0.6
    end

    def draw_shadow
        glDisable(GL_TEXTURE_2D)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glDepthMask(GL_FALSE)
        glColor4f(0, 0, 0, 0.35)
        glBegin(GL_QUADS)
            glVertex3f(-0.9, 0.01, -2.0)
            glVertex3f( 0.9, 0.01, -2.0)
            glVertex3f( 0.9, 0.01,  2.0)
            glVertex3f(-0.9, 0.01,  2.0)
        glEnd
        glColor4f(1, 1, 1, 1)
        glDepthMask(GL_TRUE)
        glDisable(GL_BLEND)
        glEnable(GL_TEXTURE_2D)
    end

    def rotation_angle
        base = (@vz || 1) >= 0 ? 0 : 180
        wobble = Math.atan2(@vx || 0, (@vz || 1).abs) * 180 / Math::PI
        wobble = -wobble if base == 180
        base + wobble * 1.5
    end

    def collision_circles
        a = rotation_angle * Math::PI / 180
        CIRCLE_OFFSETS.map {|d| [@x + d * Math.sin(a), @z + d * Math.cos(a), CIRCLE_RADIUS]}
    end

    def draw
        return if vanishing? && (Gosu.milliseconds / 60).odd? # we draw only even seconds to blink

        glPushMatrix
            glTranslatef(@x, @y, @z)
            glRotatef(rotation_angle, 0, 1, 0)
            draw_shadow
            Car.models[@type].draw(Car.texture)
        glPopMatrix
    end
end