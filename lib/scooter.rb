class Scooter
    attr_reader :x, :y, :z
    def initialize(x = 0, y = 0, z = 0)
        @x, @y, @z = x, y, z
        @model = Model3D.new('gfx/models/scooter.obj')
        @texture = GLTexture.new('gfx/lospec500-8x.png')
        
        @keys = {
            accelerate: [Gosu::KB_UP, Gosu::KB_W],
            decelerate: [Gosu::KB_DOWN, Gosu::KB_S],
            turn_left: [Gosu::KB_LEFT, Gosu::KB_A],
            turn_right: [Gosu::KB_RIGHT, Gosu::KB_D]
        }
    
        @default_angle = 90.0
        @angle = @default_angle
        @max_angle = 20.0
        @angle_speed = 60.0 # degres per second

        @speed = 0.0
        @max_speed = 20.0 # units per second
        @acceleration = 10.0 # units per second
    end

    def update(dt)
        # SPEED
        if accelerates?
            @speed += @acceleration * dt
            @speed = @max_speed if @speed > @max_speed
        else
            # brake
            if decelerates?
                @speed -= @acceleration * 2.0 * dt
            # natural deceleration
            else
                @speed -= @acceleration * 0.8 * dt if @speed > 0
            end
            @speed = 0 if @speed < 0
        end

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
        end
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

    def draw
        # side rotation if turning
        turn = @default_angle - @angle

        glPushMatrix
            glTranslatef(@x, @y, @z)
            glRotatef(turn, 0, 1, 0)
            glRotatef(-turn * 0.5, 0, 0, 1)
            @model.draw(@texture)
        glPopMatrix
    end
end