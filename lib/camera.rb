class Camera
    def initialize(scene)
        @scene = scene
        @x, @y, @z = 0, 4, -6
        @t_x, @t_y, @t_z = 0, 2, 0
        @fovy = 45.0
        @near = 0.1
        @far = 1000.0
        @distance = 3.5
        @height = 0.8
        @look_height = 0.8
        @look_ahead = 4.0
        @smoothness = 8.0
        @look_smoothness = 5.0
        @follow_smoothness = 2.5
    end

    def lerp(a, b, t)
        a + (b - a) * t
    end

    def update(dt)
        scooter = @scene.scooter
        t = 1 - Math.exp(-@smoothness * dt)
        t_look = 1 - Math.exp(-@look_smoothness * dt)
        t_follow = 1 - Math.exp(-@follow_smoothness * dt)

        target_x = scooter.x
        target_y = scooter.y + @look_height
        target_z = scooter.z + @look_ahead

        @t_x = lerp(@t_x, target_x, t_look)
        @t_y = lerp(@t_y, target_y, t)
        # @t_z = lerp(@t_z, target_z, t)
        @t_z = target_z

        @x = lerp(@x, target_x, t_follow)
        @y = lerp(@y, target_y + @height, t)
        # @z = lerp(@z, target_z - @distance, t)
        @z = scooter.z - @distance
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