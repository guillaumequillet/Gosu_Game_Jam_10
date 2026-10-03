module Debug
    def self.draw_circles(circles, color = [1, 0, 0])
        glDisable(GL_TEXTURE_2D)
        glDisable(GL_DEPTH_TEST)
        glColor3f(*color)
        circles.each do |x, z, r|
            glBegin(GL_LINE_LOOP)
                24.times do |i|
                    a = 2 * Math::PI * i / 24
                    glVertex3f(x + r * Math.cos(a), 0.05, z + r * Math.sin(a))
                end
            glEnd
        end
        glColor3f(1, 1, 1)
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_TEXTURE_2D)
    end
end
