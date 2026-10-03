class Road
    attr_reader :cars
    SEGMENT_SIZE = 10

    def initialize(scene, length = 500)
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
            road2: Model3D.new('gfx/models/road2.obj'),
            goal: Model3D.new('gfx/models/goal.obj')
        }
    end
 
    def create_segments(length)
        # todo : varier les segments, plus tard
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE) 
            length.times do |z|
                if z == length - 1
                    @models[:goal].draw(@texture, 0, 0, z * SEGMENT_SIZE)
                    next
                end
                model = @models.keys.reject {|k| k == :goal}.sample 
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

    def last_segment_z
        (@length - 1) * SEGMENT_SIZE - SEGMENT_SIZE / 2.0
    end

    def spawn_car
        z = @scene.scooter.z + 100
        angle = [90, 270].sample
        too_close = @cars.any? {|car| car.angle == angle && (car.z - z).abs < 10}
        @cars.push Car.new(angle, z) unless too_close || z > last_segment_z
        @last_spawn = Gosu.milliseconds
        @spawn_delay = Gosu.random(350, 800)
    end

    def update(dt)
        @last_spawn ||= Gosu.milliseconds
        if Gosu.milliseconds - @last_spawn > (@spawn_delay || 1000)
            spawn_car
        end

        @cars.each {|car| car.update(dt)}

        # we want to ensure that cars can't go to the last section
        @cars.each {|car| car.vanish! if !car.vanishing? && car.z > last_segment_z - 2}
        @cars.reject! {|car| car.z < @scene.scooter.z - 10 || car.vanished?}

        scooter = @scene.scooter
        @cars.each do |car|
            next if car.vanishing? || (car.z - scooter.z).abs > 5 # vanishing or too far, no need to test
            if scooter.can_be_hit? && circles_hit?(car.collision_circles, scooter.collision_circles)
                car.vanish!
                scooter.crash!
            end
        end
    end

    def circles_hit?(circles_a, circles_b)
        circles_a.any? do |ax, az, ar|
            circles_b.any? {|bx, bz, br| Math.hypot(ax - bx, az - bz) < ar + br}
        end
    end

    def draw
        # Road Drawing
        glCallList(@display_list)

        # Cars Drawing
        @cars.each do |car|
            car.draw
        end
    end

    def draw_2d
        # jauge background
        x, y, z = 10, 10, 1000
        width, height, color = @scene.window.width - 2 * x, 32, Gosu::Color::BLUE
        Gosu.draw_rect(x, y, width, height, color, z)
        
        # scooter position
        scooter_jauge_x = (@scene.scooter.z / (@length * SEGMENT_SIZE).to_f) * width
        Gosu.draw_rect(x + scooter_jauge_x, y + 10, 10, 10, Gosu::Color::WHITE, z)
    end
end