class Camera
    def initialize(window)
        @window = window
        @x, @y, @z = 0, 4, 4
        @t_x, @t_y, @t_z = 0, 2, 0
        @fovy = 45.0
        @near = 0.1
        @far = 1000.0
    end

    def look
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity
        ratio = @window.fullscreen? ? Gosu.screen_width.to_f / Gosu.screen_height.to_f : @window.width.to_f / @window.height 
        gluPerspective(@fovy, ratio, @near, @far)
        
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity
        gluLookAt(@x, @y, @z, @t_x, @t_y, @t_z, 0, 1, 0)
    end
end