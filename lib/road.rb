class Road
    SEGMENT_SIZE = 10

    def initialize(length = 100)
        @length = length
        load_assets
        create_segments(@length)
    end

    def load_assets
        @texture = GLTexture.new('gfx/funkyfuture-8-8x.png')
        @models = {
            road: Model3D.new('gfx/models/road.obj'),
            car: Model3D.new('gfx/models/car.obj')
        }
    end
 
    def create_segments(length)
        # todo : varier les segments, plus tard
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE) 
            length.times {|z| @models[:road].draw(@texture, -SEGMENT_SIZE / 2.0, 0, -z * SEGMENT_SIZE)}
        glEndList
    end

    def draw
        # dessin de la route
        glCallList(@display_list)

        # temp
        # @models[:car].draw(@texture)
    end
end