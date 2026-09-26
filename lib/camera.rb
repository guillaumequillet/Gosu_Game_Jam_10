class Camera
    def initialize(scene)
        @scene = scene
        @x, @y, @z = 0, 4, -6
        @t_x, @t_y, @t_z = 0, 2, 0
        @fovy = 45.0
        @near = 0.1
        @far = 1000.0
        @distance = 6.0
    end

    def update(dt)
        @t_x = @scene.scooter.x
        @t_y = @scene.scooter.y + 2
        @t_z = @scene.scooter.z

        @x = @t_x
        @y = @t_y 
        @z = @t_z - @distance
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