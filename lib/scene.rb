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
        @scooter = Scooter.new(self)
        @camera = Camera.new(self)
        create_road

        @music = Gosu::Song.new('music/pop_punk_magpie.mp3')
        @music.volume = 0.7
        @music.play(true)
    end

    def create_road
        @road = Road.new(self, 300)
    end

    def button_down(id)
        @debug = !@debug if id == Gosu::KB_F1
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

            if @debug
                Debug.draw_circles(@scooter.collision_circles, [0, 1, 0])
                @road.cars.each {|car| Debug.draw_circles(car.collision_circles)}
            end
        end
        draw_2d
    end

    def draw_2d
        @road.draw_2d
        @scooter.draw_2d
    end
end