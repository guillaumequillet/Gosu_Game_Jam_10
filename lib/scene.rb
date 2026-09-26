class Scene
    def initialize(window)
        @window = window
    end

    def button_down(id)

    end

    def update(dt)

    end

    def draw

    end
end

class GameScene < Scene
    def initialize(window)
        super(window)
        @scooter = Scooter.new
        @camera = Camera.new(@window)
        create_road
    end

    def create_road
        @road = Road.new
    end

    def opengl_setup
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_TEXTURE_2D)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    def update(dt)
        @scooter.update(dt)
    end

    def draw
        Gosu.gl do
            opengl_setup
            @camera.look
            @road.draw
            @scooter.draw
        end
    end
end