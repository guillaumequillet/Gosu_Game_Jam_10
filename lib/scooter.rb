class Scooter
    attr_reader :x, :y, :z, :momentum

    CIRCLE_RADIUS = 0.35
    CIRCLE_OFFSETS = [-0.45, 0.45]
    ROAD_EDGE = 3.6 # road goes from -4 to 4, minus half the scooter width

    def initialize(scene, x = 0, y = 0, z = 0)
        @scene = scene
        @x, @y, @z = x, y, z
        @scooter_model = Model3D.new('gfx/models/scooter.obj', [-0.7, 0.6, -0.4], 0.5)
        @driver_model = Model3D.new('gfx/models/driver.obj', [-0.3, 0.5, 0.8], 0.55)
        @scooter_texture = GLTexture.new('gfx/lospec500-8x.png')
        @driver_texture = GLTexture.new('gfx/texture.png')
        
        @keys = {
            accelerate: [Gosu::KB_UP, Gosu::KB_W],
            decelerate: [Gosu::KB_DOWN, Gosu::KB_S],
            turn_left: [Gosu::KB_LEFT, Gosu::KB_A],
            turn_right: [Gosu::KB_RIGHT, Gosu::KB_D]
        }
    
        @default_angle = 90.0
        @angle = @default_angle
        @max_angle = 12.0
        @angle_speed = 35.0 # degres per second

        @max_speed = 25.0 # units per second
        @speed = @max_speed
        @acceleration = 10.0 # units per second
        @momentum = 1.0 # to handle actual move measure : theme of the Jam

        @engine_sound = Gosu::Sample.new('sfx/scooter_vespa.wav')
        @engine_channel = @engine_sound.play(0.3, 0.8, true)
        @brake_sound = Gosu::Sample.new('sfx/brake_chrysler.wav')
        @brake_channel = nil
        @crash_sound = Gosu::Sample.new('sfx/crash_car.wav')

        @spin_duration = 0.5
        @spin_time = nil
        @invincible_time = 0

        @hud = {
            bg: Gosu::Image.new('gfx/fond_compteur.png', retro: true),
            needle: Gosu::Image.new('gfx/compteur_aiguille.png', retro: true)
        }
    end

    def add_momentum(value)
        @momentum = (@momentum + value).clamp(0, 1)
    end

    def update(dt)
        add_momentum((@speed / @max_speed - 0.8) * 0.4 * dt)

        if @spin_time
            @spin_time += dt
            @z -= 1.5 * dt # we want the scooter to move back a little
            if @spin_time >= @spin_duration
                @spin_time = nil
                @invincible_time = 1.0
            end
            return
        end
        @invincible_time -= dt if @invincible_time > 0

        # SPEED
        if accelerates?
            @speed += @acceleration * dt
            @speed = @max_speed if @speed > @max_speed
        else
            # brake
            if decelerates?
                @speed -= @acceleration * 3.5 * dt
                if @speed > 5 && !@brake_channel&.playing?
                    @brake_channel = @brake_sound.play(0.8 * @speed / @max_speed)
                end
            # natural deceleration
            else
                @speed -= @acceleration * 0.8 * dt if @speed > 0
            end
            @speed = 0 if @speed < 0
        end

        @brake_channel&.stop if accelerates? || !decelerates? || @speed <= 0
        @engine_channel.speed = 0.8 + (@speed / @max_speed) * 0.8

        # TURNING
        # if scooter is moving
        if @speed > 0
            if turns_left?
                @angle -= @angle_speed * dt
            elsif turns_right?
                @angle += @angle_speed * dt
            # if not turning, we want to place the scooter back to default angle
            else
                step = @angle_speed * dt * 2.0
                if @angle > @default_angle
                    @angle = [@angle - step, @default_angle].max
                else
                    @angle = [@angle + step, @default_angle].min
                end
            end

            @angle = @angle.clamp(@default_angle - @max_angle, @default_angle + @max_angle)

            @x += @speed * dt * Math.cos(@angle * Math::PI / 180.0)
            @z += @speed * dt * Math.sin(@angle * Math::PI / 180.0)

            # stay on the road, sliding along the sidewalks
            @x = @x.clamp(-ROAD_EDGE, ROAD_EDGE)
            @angle = [@angle, @default_angle].max if @x >= ROAD_EDGE
            @angle = [@angle, @default_angle].min if @x <= -ROAD_EDGE
        end
    end

    def stop_sounds
        @engine_channel.stop
        @brake_channel&.stop
    end

    def crash!
        add_momentum(-0.15)
        @crash_sound.play(0.8 + 0.2 * @speed / @max_speed, Gosu.random(0.85, 1.15))
        @speed *= 0.5
        @angle = @default_angle
        @spin_time = 0
        @brake_channel&.stop
        @engine_channel.speed = 0.8
    end

    def can_be_hit?
        @spin_time.nil? && @invincible_time <= 0
    end

    def accelerates? 
        @keys[:accelerate].any? {|k| Gosu.button_down?(k)}
    end
    
    def decelerates? 
        @keys[:decelerate].any? {|k| Gosu.button_down?(k)}
    end
 
    def turns_left? 
        @keys[:turn_left].any? {|k| Gosu.button_down?(k)}
    end
    
    def turns_right? 
        @keys[:turn_right].any? {|k| Gosu.button_down?(k)}
    end

    def collision_circles
        a = (@default_angle - @angle) * Math::PI / 180 # same "turn" as in draw
        CIRCLE_OFFSETS.map {|d| [@x + d * Math.sin(a), @z + d * Math.cos(a), CIRCLE_RADIUS]}
    end

    def draw_shadow
        glDisable(GL_TEXTURE_2D)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glDepthMask(GL_FALSE)
        glColor4f(0, 0, 0, 0.35)
        glBegin(GL_QUADS)
            glVertex3f(-0.25, 0.01, -0.95)
            glVertex3f( 0.25, 0.01, -0.95)
            glVertex3f( 0.25, 0.01,  0.95)
            glVertex3f(-0.25, 0.01,  0.95)
        glEnd
        glColor4f(1, 1, 1, 1)
        glDepthMask(GL_TRUE)
        glDisable(GL_BLEND)
        glEnable(GL_TEXTURE_2D)
    end

    def draw
        # side rotation if turning
        turn = @default_angle - @angle
        return if @invincible_time > 0 && (Gosu.milliseconds / 80).odd?

        spin = 0
        if @spin_time
            t = @spin_time / @spin_duration
            spin = 360 * t * (2 - t)
        end

        glEnable(GL_ALPHA_TEST)
        glAlphaFunc(GL_GREATER, 0)
        glPushMatrix
            glTranslatef(@x, @y, @z)
            glRotatef(turn + spin, 0, 1, 0)
            draw_shadow
            glRotatef(-turn * 0.5, 0, 0, 1)
            @scooter_model.draw(@scooter_texture)
            @driver_model.draw(@driver_texture)
        glPopMatrix
        glDisable(GL_ALPHA_TEST)
    end

    def draw_counter
        x = 10
        y = @scene.window.height - @hud[:bg].height - x
        z = 1000
        @hud[:bg].draw(x, y, z)
        x += 64
        y += 64
        min_angle, max_angle = -224, 48
        ratio = (@speed / @max_speed).clamp(0, 1)
        angle = min_angle + (max_angle - min_angle) * ratio
        @hud[:needle].draw_rot(x, y, z, angle, 0, 0.5, 0.8, 1.0)
    end

    def draw_momentum
        w, h = 150, 16
        gx = @scene.window.width - w - 10
        gy = @scene.window.height - h - 10
        color = @momentum < 0.25 && (Gosu.milliseconds / 150).odd? ? Gosu::Color::RED : Gosu::Color::GREEN
        Gosu.draw_rect(gx, gy, w, h, Gosu::Color::BLACK, 1000)
        Gosu.draw_rect(gx + 2, gy + 2, (w - 4) * @momentum, h - 4, color, 1000)
    end

    def draw_2d
        draw_counter
        draw_momentum
    end
end