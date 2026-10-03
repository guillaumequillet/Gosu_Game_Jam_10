class Bonus
    attr_reader :z

    RADIUS = 0.35

    def self.model
        @model ||= Model3D.new('gfx/models/bonus.obj')
    end

    def self.texture
        @texture ||= GLTexture.new('gfx/lospec500-8x.png')
    end

    def self.sound
        @sound ||= Gosu::Sample.new('sfx/bonus.wav')
    end

    def initialize(x, z)
        @x, @z = x, z
        @angle = 0
    end

    def update(dt)
        @angle += 120 * dt
    end

    def collision_circles
        [[@x, @z, RADIUS]]
    end

    def draw_shadow
        glDisable(GL_TEXTURE_2D)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glDepthMask(GL_FALSE)
        glColor4f(0, 0, 0, 0.35)
        glBegin(GL_TRIANGLE_FAN)
            glVertex3f(0, 0.01, 0)
            17.times do |i|
                a = 2 * Math::PI * i / 16
                glVertex3f(0.25 * Math.cos(a), 0.01, 0.25 * Math.sin(a))
            end
        glEnd
        glColor4f(1, 1, 1, 1)
        glDepthMask(GL_TRUE)
        glDisable(GL_BLEND)
        glEnable(GL_TEXTURE_2D)
    end

    def draw
        glPushMatrix
            glTranslatef(@x, 0, @z)
            draw_shadow
        glPopMatrix

        glPushMatrix
            glTranslatef(@x, 0.5 + 0.1 * Math.sin(@angle * Math::PI / 90), @z)
            glRotatef(@angle, 0, 1, 0)
            Bonus.model.draw(Bonus.texture)
        glPopMatrix
    end
end
