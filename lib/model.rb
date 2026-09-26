class Model3D
    LIGHT_DIR = [0, 1 ,0]
    AMBIENT = 0.4

    def initialize(filename)
        @vertices = []
        @texture_vertices = []
        @normals = []
        @faces = []
        File.open(filename, 'r').readlines.each do |line|
            data = line.split(' ')
            case data[0]
            when 'v'
                @vertices.push data.drop(1).map {|e| e.to_f}
            when 'vt'
                @texture_vertices.push data.drop(1).map {|e| e.to_f}
            when 'vn'
                @normals.push data.drop(1).map {|e| e.to_f}
            when 'f'
                @faces.push data.drop(1).map {|i| i.split('/').map {|j| j.to_i - 1}} # obj counts from 1, not 0
            end
        end
        compile_display_list
    end

    def compile_display_list
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE)
            glBegin(GL_TRIANGLES)
                @faces.each do |face|
                    face.each do |vertex_info|
                        v = @vertices[vertex_info[0]]
                        vt = @texture_vertices[vertex_info[1]]
                        vn = @normals[vertex_info[2]]
                        light = [0, vn.zip(LIGHT_DIR).sum {|a, b| a * b}].max
                        intensity = AMBIENT + (1 - AMBIENT) * light
                        glColor3f(intensity, intensity, intensity)
                        glTexCoord2d(vt[0], 1.0 - vt[1]) # we invert texture in height
                        glVertex3f(*v)
                    end
                end
            glEnd
            glColor3f(1, 1, 1)
        glEndList
    end

    def draw(texture, x = 0, y = 0, z = 0)
        glBindTexture(GL_TEXTURE_2D, texture.get_id)

        glPushMatrix
        glTranslatef(x, y, z)
            glCallList(@display_list)
        glPopMatrix
    end
end

class GLTexture
    attr_reader :width, :height

    def initialize(filename)
        gosu_image = filename.is_a?(Gosu::Image) ? filename : Gosu::Image.new(filename, retro: true)
        array_of_pixels = gosu_image.to_blob
        tex_name_buf = ' ' * 4
        glGenTextures(1, tex_name_buf)
        @tex_name = tex_name_buf.unpack('L')[0]
        glBindTexture( GL_TEXTURE_2D, @tex_name )
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gosu_image.width, gosu_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)

        @width  = gosu_image.width
        @height = gosu_image.height
        gosu_image = nil
    end

    def get_id
        return @tex_name
    end

    def self.load_tiles(filename, width, height)
        temp_tileset = Gosu::Image.load_tiles(filename, width, height, retro: true)
        textures = []
        temp_tileset.each do |tile|
            textures.push GLTexture.new(tile)
        end
        return textures
    end
end
