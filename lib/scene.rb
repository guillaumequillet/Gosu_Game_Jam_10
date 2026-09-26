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
    attr_reader :window, :scooter
    def initialize(window)
        super(window)
        @scooter = Scooter.new
        @camera = Camera.new(self)
        create_road
    end

    def create_road
        @road = Road.new(self)
    end

    def opengl_setup
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_TEXTURE_2D)
        glClearColor(0.2, 0.5, 0.8, 0.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    def update(dt)
        @scooter.update(dt)
        @road.update(dt)
        @camera.update(dt)
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