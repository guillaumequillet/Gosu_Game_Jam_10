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
        @camera = Camera.new(@window)
        load_assets
    end

    def load_assets
        @texture = GLTexture.new('gfx/funkyfuture-8-8x.png')
        @models = {
            car: Model3D.new('gfx/models/car.obj')
        }
    end

    def opengl_setup
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_TEXTURE_2D)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    def draw
        Gosu.gl do
            opengl_setup
            @camera.look
            @angle ||= 0; @angle += 1
            glRotatef(@angle, 0, 1, 0)
            @models[:car].draw(@texture)
        end
    end
end