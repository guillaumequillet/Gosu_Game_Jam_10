class Road
    attr_reader :cars
    SEGMENT_SIZE = 10

    def initialize(scene, length = 100)
        @scene = scene
        @length = length
        load_assets
        create_segments(@length)
        @cars = []
    end

    def load_assets
        @texture = GLTexture.new('gfx/lospec500-8x.png')
        @models = {
            road: Model3D.new('gfx/models/road.obj'),
            road2: Model3D.new('gfx/models/road2.obj')
        }
    end
 
    def create_segments(length)
        # todo : varier les segments, plus tard
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE) 
            length.times do |z|
                model = @models.keys.sample 
                reverse = [true, false].sample
                if reverse
                    glPushMatrix
                    glScalef(-1, 1, 1)
                end
                @models[model].draw(@texture, 0, 0, z * SEGMENT_SIZE)
                glPopMatrix if reverse
            end
        glEndList
    end

    def spawn_car
        z = @scene.scooter.z + 100
        angle = [90, 270].sample
        too_close = @cars.any? {|car| car.angle == angle && (car.z - z).abs < 10}
        @cars.push Car.new(angle, z) unless too_close
        @last_spawn = Gosu.milliseconds
        @spawn_delay = Gosu.random(350, 800)
    end

    def update(dt)
        @last_spawn ||= Gosu.milliseconds
        if Gosu.milliseconds - @last_spawn > (@spawn_delay || 1000)
            spawn_car
        end

        @cars.each {|car| car.update(dt)}
        @cars.reject! {|car| car.z < @scene.scooter.z - 10}

        scooter = @scene.scooter
        @cars.each do |car|
            next if (car.z - scooter.z).abs > 5 # too far, no need to test
            if circles_hit?(car.collision_circles, scooter.collision_circles)
                puts "CRASH"
            end
        end
    end

    def circles_hit?(circles_a, circles_b)
        circles_a.any? do |ax, az, ar|
            circles_b.any? {|bx, bz, br| Math.hypot(ax - bx, az - bz) < ar + br}
        end
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