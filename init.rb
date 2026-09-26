require 'gosu'
require 'opengl'
require 'glu'

OpenGL.load_lib
GLU.load_lib

include OpenGL, GLU

Dir.glob("lib/*.rb").each {|fn| require_relative fn}

class Window < Gosu::Window
    def initialize
        super(640, 480, false)
        self.caption = 'Gosu Game Jam 10'
        @scene = GameScene.new(self)
    end

    def button_down(id)
        super
        close! if id == Gosu::KB_ESCAPE
        @scene.button_down(id)
    end

    def update
        @dt ||= Gosu.milliseconds
        delta = Gosu.milliseconds - @dt
        @scene.update(delta)
        @dt = Gosu.milliseconds
    end

    def draw
        @scene.draw
    end
end

Window.new.show
