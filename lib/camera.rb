class Camera
    def initialize(scene)
        @scene = scene
        @x, @y, @z = 0, 4, -6
        @t_x, @t_y, @t_z = 0, 2, 0
        @fovy = 45.0
        @near = 0.1
        @far = 1000.0
        @distance = 4.0
        @smoothness = 8.0
    end

    def lerp(a, b, t)
        a + (b - a) * t
    end

    def update(dt)
        scooter = @scene.scooter
        t = 1 - Math.exp(-@smoothness * dt)

        target_x = scooter.x
        target_y = scooter.y + 2
        target_z = scooter.z

        @t_x = lerp(@t_x, target_x, t)
        @t_y = lerp(@t_y, target_y, t)
        @t_z = lerp(@t_z, target_z, t)

        @x = lerp(@x, target_x, t)
        @y = lerp(@y, target_y, t)
        @z = lerp(@z, target_z - @distance, t)
    end

    def look
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity
        ratio = @scene.window.fullscreen? ? Gosu.screen_width.to_f / Gosu.screen_height.to_f : @scene.window.width.to_f / @scene.window.height 
        gluPerspective(@fovy, ratio, @near, @far)
        
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity
        gluLookAt(@x, @y, @z, @t_x, @t_y, @t_z, 0, 1, 0)
    end
end