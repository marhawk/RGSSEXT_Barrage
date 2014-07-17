module Mouse
  GetCursorPos = Win32API.new("user32", "GetCursorPos", 'p', 'i')
  ScreenToClient = Win32API.new("user32", "ScreenToClient", 'ip', 'i')
  GetActiveWindow = Win32API.new("user32", "GetActiveWindow", nil, 'l')
  ShowCursor = Win32API.new("user32", "ShowCursor", 'i', 'l')
  Window_HWND = GetActiveWindow.call
  def self.pos
    point_var = [0, 0].pack('ll')
    if GetCursorPos.call(point_var) != 0
      if ScreenToClient.call(Window_HWND, point_var) != 0
        x, y = point_var.unpack('ll')
        return x, y
      else
        return 0, 0
      end
    else
      return 0, 0
    end
  end
end
Mouse::ShowCursor.call(0)

class HCl
  attr_accessor :route
  attr_accessor :particle
	def initialize
		@imp = 0
		@particle = []
		@particle2 = []
		@screen_width = 640
		@screen_height = 480
		@route = Hash.new
		@scene = Table.new(@screen_width+1,@screen_height+1)
	end
	def imp(d)
		return @imp % d == 0
	end
	def init_particle
		@p_scene = Sprite.new($scene.spriteset.viewport1)
		@p_scene2 = Sprite.new($scene.spriteset.viewport1)
    @pbitmap = Bitmap.new(@screen_width,@screen_height)
    @pbitmap2 = Bitmap.new(@screen_width,@screen_height)
		@p_scene.bitmap = @pbitmap
		@p_scene2.bitmap = @pbitmap2
    update_particle
	end
	def update_particle
		@imp = 0 if (@imp += 1) == 65535
    @pbitmap.clear
    @pbitmap2.clear
		@particle.delete_if{|w|
      (w[0]>=w[7])||
      !@scene[(w[2]=w[4]+w[6][w[1],w[0],0]),(w[3]=w[5]+w[6][w[1],w[0],1])]||
      @pbitmap.blt(w[2]-w[8],w[3]-w[9],w[10],w[11])||
      !(w[0]+=1)
    }
		@particle2.delete_if{|w|
      (w[0]>=w[7])||
      !@scene[(w[2]=w[4]+w[6][w[1],w[0],0]),(w[3]=w[5]+w[6][w[1],w[0],1])]||
      @pbitmap2.blt(w[2]-w[8],w[3]-w[9],w[10],w[11])||
      !(w[0]+=1)
    }
    update_battle
	end
	def fire(std_x,std_y,route,style)
		@particle.push([0,style,std_x,std_y,std_x,std_y,@route[route][1],@route[route][2],@route[route][3],@route[route][4],@route[route][0],@route[route][5]])#,@route[route][6]])
	end
	def fire2(std_x,std_y,route,style)
		@particle2.push([0,style,std_x,std_y,std_x,std_y,@route[route][1],@route[route][2],@route[route][3],@route[route][4],@route[route][0],@route[route][5]])#,@route[route][6]])
	end
end

$hcl = HCl.new

class HCl
  def init_battle
    @hashes = {}
    @avg = 0.0
    @last = 0
    @det = 0
  end
  def rgssext_bitmargbcomp02(a,b,x,y)
    at = [true]*255
    result = 0
    t0 = Time.new
    if (rand < (($game_player.slow) ? 0.8 : 0.1)) && (@det>2) && @avg > 0.9
      debug = ";Type:Accurate"
      result = 0
      posy = 0
      loop do
        g = 0
        for posx in 0..x+a.width
          c = a.get_pixel(posx,posy)
          d = b.get_pixel(posx+x,posy+y)
          if c.red == 255 && d.blue==255 && d.green > 200 && at[d.green]
            at[d.green] = false
            result += 1
            g += 1
          end
        end
        posy += rand([[a.height/8,1].max,32].min)
        break if posy > a.height
      end
      @last = result
    elsif @avg > 1.1 && @det < 0.9 && @det > 0.5
      debug = ";TYPE:DEDUCTION"
      result = @avg.round
      @det *= 1.1
    else
      debug = ";Type:About"
      posx = rand(a.width)
      posy = 3*a.height/5+rand(a.height/5)
      posy = 3*a.height/5+rand(a.height/5)
      d = b.get_pixel(posx+x,posy+y)
      if d.blue==255 && d.green > 200 && at[d.green]
        at[d.green] = false
        result +=1
      end
      round = 1
      until Time.new-t0 > (($game_player.slow) ? 0.005 : 0.001)
        posx = rand(a.width)
        posy = 2*a.height/3+rand(a.height/3)
        until a.get_pixel(posx,posy).alpha < 127
          posy = 2*a.height/3+rand(a.height/3)
          d = b.get_pixel(posx+x,posy+y)
          if d.blue==255 && d.green > 200 && at[d.green]
            at[d.green] = false
            result +=1
          end
        end
        round += 1
      end
    end
    $GameConsole.puts sprintf("%06d:hits(cur=%03d||avg=%09.6f det=%09.6f||)|in:%.3f@"+debug,
    Graphics.frame_count,result,
    @avg=(@avg+result)/2,@det=(@det+(@last-@avg).abs)/2,
    Time.new-t0) if result > 0
    return result
  end
  def update_battle
    c = @pbitmap.get_pixel($game_player.screen_x,$game_player.screen_y)
    $GameConsole.puts sprintf("%06d:Game_over,%03d,%03d:%03d|%03d|%03d|-%03d",
    Graphics.frame_count,$game_player.screen_x,$game_player.screen_y,
    c.red,c.green,c.blue,c.alpha) if c.alpha >= 254
    #$scene = Scene_Gameover.new if @pbitmap.get_pixel($game_player.screen_x,$game_player.screen_y).red == 254
    @hashes.each do|k,w|
      if !$game_self_switches[[$game_map.map_id,k,'A']]&&
          (w[1]-=rgssext_bitmargbcomp02(w[0],
          @pbitmap2,$game_map.events[k].screen_x-w[0].width/2,
          $game_map.events[k].screen_y-w[0].height/2)) < 0
        $game_self_switches[[$game_map.map_id,k,'A']] = true
        $game_map.need_refresh = true
      end
    end
  end
  def set_battle_hash(i,str,hp)
    @hashes[i] = [RPG::Cache.character(str+'_pdd',0),hp]
  end
end
class Game_Map
  if @self_alias == nil
    alias self_update update
    alias self_setup setup
    @self_alias = true
  end
  def setup(map_id)
    $hcl.init_battle
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    @display_x = 0
    @display_y = 0
    @need_refresh = false
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
      $hcl.set_battle_hash(i,@map.events[i].pages[0].graphic.character_name,
      @map.events[i].pages[0].list[0].parameters[0].to_i
      ) if @map.events[i].pages[0].list[0].code == 108
    end
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  def update;$hcl.update_particle;self_update;end
  def passable2?(x,y)
    return false unless valid?(x, y)
    for i in [2, 1, 0]
      tile_id = data[x, y, i]
      return false if tile_id == nil
      return false if @passages[tile_id] & 0x0f == 0x0f
    end
    return true
  end
  def scroll_down(distance)
    d = @display_y + distance - (self.height - 15) * 128
    if d <= 0
      $hcl.particle.each{|w|w[5] = (w[5] - distance/4)}
      @display_y = @display_y + distance
    else
      $hcl.particle.each{|w|w[5] = (w[5] - (distance-d)/4)}
      @display_y = (self.height - 15) * 128
    end
  end
  def scroll_left(distance)
    d = @display_x - distance
    if d >= 0
      $hcl.particle.each{|w|w[4] = (w[4] + distance/4)}
      @display_x = @display_x - distance
    else
      $hcl.particle.each{|w|w[4] = (w[4] - @display_x/4)}
      @display_x = 0
    end
  end
  def scroll_right(distance)
    d = @display_x + distance - (self.width - 20) * 128
    if d <= 0
      $hcl.particle.each{|w|w[4] = (w[4] - distance/4)}
      @display_x = @display_x + distance
    else
      $hcl.particle.each{|w|w[4] = (w[4] - (distance-d)/4)}
      @display_x = (self.width - 20) * 128
    end
  end
  def scroll_up(distance)
    d = @display_y - distance
    if d >= 0
      $hcl.particle.each{|w|w[5] = (w[5] + distance/4)}
      @display_y = @display_y - distance
    else
      $hcl.particle.each{|w|w[5] = (w[5] - @display_y/4)}
      @display_y = 0
    end
  end
end
class Scene_Map    ;attr_accessor :spriteset;end
class Spriteset_Map;attr_accessor :viewport1;end
class Game_Event   ;attr_accessor :id       ;end
class Game_Player
  attr_accessor :slow
  def update
    unless $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      case Input.dir4
      when 2
        $game_map.scroll_down(16)
      when 4
        $game_map.scroll_left(16)
      when 6
        $game_map.scroll_right(16)
      when 8
        $game_map.scroll_up(16)
      end
      if Input.trigger?(Input::C)
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
      if Input.press?(Input::CTRL)
        @character_name = "001-Fighter01_s"
        @slow = true
        Graphics.frame_rate = 36
      else
        @character_name = "001-Fighter01_f"
        @slow = false
        Graphics.frame_rate = 60
      end
      if Input.press?(Input::A)
        if $hcl.imp(3)
          $hcl.fire2(screen_x,screen_y,"default",270)
        end
      end
    end
    a,b = Mouse.pos
    @real_x = ([[a,0].max,640].min - 16) * 4 - 3 + $game_map.display_x
    @real_y = ([[b,0].max,480].min - 32) * 4 - 3 + $game_map.display_y
    super
  end        
  def update_move
    @x = @real_x / 128
    @y = @real_y / 128
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
end
class Sprite_Character < RPG::Sprite
  def update
    super
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        self.bitmap = RPG::Cache.character(@character.character_name,
          @character.character_hue)
        @cw = bitmap.width / 4
        @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch / 2
      end
    end
    self.visible = (not @character.transparent)
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end

		$hcl.route["default"] = [
    Bitmap.new("Graphics/Particles/0.png"),Table.new(360,75,2),nil,nil,nil,nil,nil]
		(0..$hcl.route["default"][1].xsize).each do |s|
			(0..$hcl.route["default"][1].ysize).each do |w|
				$hcl.route["default"][1][s,w,0]=(6.25*w*Math.cos(Math::PI*s/180)).round
				$hcl.route["default"][1][s,w,1]=(6.25*w*Math.sin(Math::PI*s/180)).round
				$hcl.route["default"][1][s,w,2]=s
			end
		end
		$hcl.route["default"][2] = $hcl.route["default"][1].ysize
		$hcl.route["default"][3] = $hcl.route["default"][0].width/2
		$hcl.route["default"][4] = $hcl.route["default"][0].height/2
		$hcl.route["default"][5] = $hcl.route["default"][0].rect
    
    $hcl.route["default2"] = [
    Bitmap.new("Graphics/Particles/1.png"),Table.new(360,75,2),nil,nil,nil,nil,nil]
		(0..$hcl.route["default2"][1].xsize).each do |s|
			(0..$hcl.route["default2"][1].ysize).each do |w|
				$hcl.route["default2"][1][s,w,0]=(6.25*w*Math.cos(Math::PI*s/180)).round
				$hcl.route["default2"][1][s,w,1]=(6.25*w*Math.sin(Math::PI*s/180)).round
				$hcl.route["default2"][1][s,w,2]=s
			end
		end
		$hcl.route["default2"][2] = $hcl.route["default2"][1].ysize
		$hcl.route["default2"][3] = $hcl.route["default2"][0].width/2
		$hcl.route["default2"][4] = $hcl.route["default2"][0].height/2
		$hcl.route["default2"][5] = $hcl.route["default2"][0].rect

    $hcl.route["circlea"] = [
    Bitmap.new("Graphics/Particles/2.png"),Table.new(360,150,2),nil,nil,nil,nil,nil]
		(0..$hcl.route["circlea"][1].xsize).each do |s|
      s2=s
			(0..$hcl.route["circlea"][1].ysize).each do |w|
				$hcl.route["circlea"][1][s,w,0]=((0.001*(w-50)**3+125)*Math.cos(Math::PI*s2/180)).round
				$hcl.route["circlea"][1][s,w,1]=((0.001*(w-50)**3+125)*Math.sin(Math::PI*s2/180)).round
				$hcl.route["circlea"][1][s,w,2]=s
        s2=(s2+1)%360
			end
		end
		$hcl.route["circlea"][2] = $hcl.route["circlea"][1].ysize
		$hcl.route["circlea"][3] = $hcl.route["circlea"][0].width/2
		$hcl.route["circlea"][4] = $hcl.route["circlea"][0].height/2
		$hcl.route["circlea"][5] = $hcl.route["circlea"][0].rect
    
    $hcl.route["circleb"] = [
    Bitmap.new("Graphics/Particles/2.png"),Table.new(360,150,2),nil,nil,nil,nil,nil]
		(0..$hcl.route["circleb"][1].xsize).each do |s|
      s2=s
			(0..$hcl.route["circleb"][1].ysize).each do |w|
				$hcl.route["circleb"][1][s,w,0]=((0.001*(w-50)**3+125)*Math.cos(Math::PI*s2/180)).round
				$hcl.route["circleb"][1][s,w,1]=((0.001*(w-50)**3+125)*Math.sin(Math::PI*s2/180)).round
				$hcl.route["circleb"][1][s,w,2]=s
        s2=(s2-1)%360
			end
		end
		$hcl.route["circleb"][2] = $hcl.route["circleb"][1].ysize
		$hcl.route["circleb"][3] = $hcl.route["circleb"][0].width/2
		$hcl.route["circleb"][4] = $hcl.route["circleb"][0].height/2
		$hcl.route["circleb"][5] = $hcl.route["circleb"][0].rect

    $hcl.route["circle2"] = [
    Bitmap.new("Graphics/Particles/3.png"),Table.new(360,150,2),nil,nil,nil,nil,nil]
		(0..$hcl.route["circle2"][1].xsize).each do |s|
			(0..$hcl.route["circle2"][1].ysize).each do |w|
				$hcl.route["circle2"][1][s,w,0]=((0.001*(w-50)**3+125)*Math.cos(Math::PI*s/180)).round
				$hcl.route["circle2"][1][s,w,1]=((0.001*(w-50)**3+125)*Math.sin(Math::PI*s/180)).round
				$hcl.route["circle2"][1][s,w,2]=s
			end
		end
		$hcl.route["circle2"][2] = $hcl.route["circle2"][1].ysize
		$hcl.route["circle2"][3] = $hcl.route["circle2"][0].width/2
		$hcl.route["circle2"][4] = $hcl.route["circle2"][0].height/2
		$hcl.route["circle2"][5] = $hcl.route["circle2"][0].rect

