class Road
    SEGMENT_SIZE = 10

    def initialize(scene, length = 100)
        @scene = scene
        @length = length
        load_assets
        create_segments(@length)
        @cars = []
    end

    def load_assets
        @texture = GLTexture.new('gfx/funkyfuture-8-8x.png')
        @models = {
            road: Model3D.new('gfx/models/road.obj')
        }
    end
 
    def create_segments(length)
        # todo : varier les segments, plus tard
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE) 
            length.times {|z| @models[:road].draw(@texture, -SEGMENT_SIZE / 2.0, 0, z * SEGMENT_SIZE)}
        glEndList
    end

    def spawn_car
        z = @scene.scooter.z + 100
        angle = [90, 270].sample
        @cars.push Car.new(angle, z)
        @last_spawn = Gosu.milliseconds
    end

    def update(dt)
        @last_spawn ||= Gosu.milliseconds
        if Gosu.milliseconds - @last_spawn > 2000
            spawn_car
        end

        @cars.each {|car| car.update(dt)}
        @cars.reject! {|car| car.z < @scene.scooter.z - 10}
    end

    def draw
        # dessin de la route
        glCallList(@display_list)

        # dessin des voitures
        @cars.each do |car|
            car.draw
        end
    end
end