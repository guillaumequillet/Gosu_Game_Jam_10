class Road
    attr_reader :cars
    SEGMENT_SIZE = 10

    def initialize(scene, length = 500)
        @scene = scene
        @length = length
        load_assets
        create_segments(@length)
        @cars = []
        @bonuses = []
    end

    def load_assets
        @texture = GLTexture.new('gfx/lospec500-8x.png')
        @models = {
            road: Model3D.new('gfx/models/road.obj'),
            road2: Model3D.new('gfx/models/road2.obj'),
            goal: Model3D.new('gfx/models/goal.obj')
        }
        @hud = {
            scooter: Gosu::Image.new('gfx/scooter_icon.png', retro: true),
            goal: Gosu::Image.new('gfx/goal.png', retro: true)
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

    def progress
        (@scene.scooter.z / (last_segment_z + SEGMENT_SIZE / 2.0)).clamp(0, 1)
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

        # more spawns at the end
        @spawn_delay = Gosu.random(350, 800) * (1.0 - 0.5 * progress)
    end

    def spawn_bonus
        z = @scene.scooter.z + 100
        @bonuses.push Bonus.new(Gosu.random(-3.5, 3.5), z) unless z > last_segment_z
        @last_bonus = Gosu.milliseconds
        @bonus_delay = Gosu.random(2000, 5000)
    end

    def update(dt)
        # car spawn
        @last_spawn ||= Gosu.milliseconds
        if Gosu.milliseconds - @last_spawn > (@spawn_delay || 1000)
            spawn_car
        end

        # bonus spawn
        @last_bonus ||= Gosu.milliseconds
        spawn_bonus if Gosu.milliseconds - @last_bonus > (@bonus_delay || 3000)

        # car update
        @cars.each {|car| car.update(dt)}

        # we want to ensure that cars can't go to the last section
        @cars.each {|car| car.vanish! if !car.vanishing? && car.z > last_segment_z - 2}
        @cars.reject! {|car| car.z < @scene.scooter.z - 10 || car.vanished?}

        # bonus update
        @bonuses.each {|bonus| bonus.update(dt)}

        # we remove the bonus if we passed it
        @bonuses.reject! {|bonus| bonus.z < @scene.scooter.z - 10}

        # or if we took it
        @bonuses.reject! do |bonus|
            taken = circles_hit?(bonus.collision_circles, @scene.scooter.collision_circles)
            if taken
                @scene.scooter.add_momentum(0.15)
                Bonus.sound.play(0.8)
            end
            taken
        end

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
        @cars.each {|car| car.draw }
        
        # Bonus Drawing
        @bonuses.each {|bonus| bonus.draw }
    end

    def draw_2d
        z = 1000
        margin = 10
        bar_x = margin
        bar_w = @scene.window.width - 2 * margin
        bar_y = margin + @hud[:goal].height
        goal_x = bar_x + bar_w - @hud[:goal].width

        scooter_x = bar_x + (goal_x - bar_x - @hud[:scooter].width) * progress

        Gosu.draw_rect(bar_x, bar_y - 3, bar_w, 6, Gosu::Color.rgba(0, 0, 0, 120), z)
        Gosu.draw_rect(bar_x, bar_y - 3, scooter_x + 54 - bar_x, 6, Gosu::Color.rgba(255, 200, 40, 255), z)
        @hud[:goal].draw(goal_x, bar_y - @hud[:goal].height, z)
        @hud[:scooter].draw(scooter_x, bar_y - @hud[:scooter].height, z)
    end
end