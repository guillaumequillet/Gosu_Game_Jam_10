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

        @elapsed = 0
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
        @elapsed += dt
        @scooter.update(dt)
        @road.update(dt)
        @camera.update(dt)
        return game_over if @scooter.momentum <= 0
        success if @road.progress >= 1
    end

    def game_over
        @scooter.stop_sounds
        @music.stop
        @window.scene = GameOverScene.new(@window)
    end

    def success
        @scooter.stop_sounds
        @music.stop
        @window.scene = SuccessScene.new(@window, @elapsed, @road.bonus_taken, @road.bonus_spawned)
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

class GameOverScene < Scene
    def initialize(window)
        super(window)
        @big_font = Gosu::Font.new(48)
        @small_font = Gosu::Font.new(20)
    end

    def button_down(id)
        @window.scene = GameScene.new(@window)
    end

    def draw
        cx, cy = @window.width / 2, @window.height / 2
        @big_font.draw_text_rel('GAME OVER', cx, cy - 20, 0, 0.5, 0.5)
        @small_font.draw_text_rel('Press any key to retry !', cx, cy + 30, 0, 0.5, 0.5, 1, 1, Gosu::Color::GRAY)
    end
end

class SuccessScene < Scene
    def initialize(window, elapsed, bonus_taken, bonus_spawned)
        super(window)
        @big_font = Gosu::Font.new(48)
        @small_font = Gosu::Font.new(20)
        @time = format('%d:%02d', elapsed / 60, elapsed % 60)
        @bonus = "#{bonus_taken} / #{bonus_spawned}"
    end

    def button_down(id)
        @window.scene = GameScene.new(@window)
    end

    def draw
        x, y = @window.width / 2, @window.height / 2
        @big_font.draw_text_rel('You made it !', x, y - 40, 0, 0.5, 0.5)
        @small_font.draw_text_rel("Time : #{@time}", x, y + 10, 0, 0.5, 0.5)
        @small_font.draw_text_rel("Bonus : #{@bonus}", x, y + 35, 0, 0.5, 0.5)
        @small_font.draw_text_rel('Press any key to retry.', x, y + 75, 0, 0.5, 0.5, 1, 1, Gosu::Color::GRAY)
    end
end