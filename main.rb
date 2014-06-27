module Mouse
  GetCursorPos = Win32API.new("user32", "GetCursorPos", 'p', 'i')
  ScreenToClient = Win32API.new("user32", "ScreenToClient", 'ip', 'i')
  GetActiveWindow = Win32API.new("user32", "GetActiveWindow", nil, 'l')
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
module HCL
  class Particle < RPG::Sprite
    attr_accessor :main_route
    attr_accessor :stdx
    attr_accessor :stdy
    attr_accessor :style
    attr_accessor :standpoint
    def initialize(viewport);super(viewport);@t=0;end
    def update
      if @t >= @main_route.ysize;self.x=self.y=-256;return;end
      self.x=@stdx+@main_route[@style,@t,0]
      self.y=@stdy+@main_route[@style,@t,1]
      @t+=1
      super
    end
    def realx;return ((self.x - 16) * 4 - 3 + $game_map.display_x);end
    def realy;return ((self.y - 32) * 4 - 3 + $game_map.display_y);end
  end
end
class HCl
  def bullets;return @bullet;end
  def command_damage(w,event)
    if event.is_a?(Game_Player) && w.standpoint == 1
      Graphics.update
      $scene = Scene_Gameover.new
    end
    if event.is_a?(Game_Event) && w.standpoint == 0
      Graphics.update
      $game_self_switches[[$game_map.map_id,event.id,'A']] = true
      $game_map.need_refresh = true
    end
  end
  def imp(d)
    return @imp % (@im[d]) <= d
  end
  def superfire(x,y,route,emitter,standpoint)
    eval(sprintf(@emitter[emitter],x,y))
  end
  def fire(x,y,route,style,standpoint)
    return unless $scene.is_a?(Scene_Map)
    r = @cache[route]
    sprite = HCL::Particle.new($scene.spriteset.viewport1)
    sprite.stdx = sprite.x = x
    sprite.stdy = sprite.y = y
    sprite.bitmap = r[0]
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.main_route = r[1]
    sprite.style = style
    sprite.standpoint = standpoint
    @bullet.push(sprite)
  end
  def initialize
    @imp = 0
    @im  = [1,6,60,120,150]
    @bullet = []
  end
  def update
    @imp = 0 if @imp == 65535
    @imp += 1
    @cursor = Array.new(641){Array.new(481,nil)}
    @bullet.each do |w|
      w.update
      d = $game_map.passable2?((w.realx/128.0).round, (w.realy/128.0).round)
      if w.x<0||w.y<0||w.x>=640||w.y>=480||!d then w.dispose
      else
        unless @cursor[w.x  ][w.y  ] then @cursor[w.x  ][w.y  ] = w end
        unless @cursor[w.x+1][w.y  ] then @cursor[w.x+1][w.y  ] = w end
        unless @cursor[w.x  ][w.y+1] then @cursor[w.x  ][w.y+1] = w end
        unless @cursor[w.x+1][w.y+1] then @cursor[w.x+1][w.y+1] = w end
      end
    end
    for event in $game_map.events.values+[$game_player]
      a = event.screen_x
      b = event.screen_y
      w = @cursor[a][b] unless a<0||a>=640||b<0||b>=480
      command_damage(w,event) unless w == nil
    end
    @bullet.delete_if {|w| w.disposed? }
  end
  def loadcache(w)
    f=File.open(w,"rb");@cache=Marshal.load(f);f.close
    @cache.each{|key, value|@cache[key] = [Bitmap.new(value[0]),value[1]]}
  end
  def makecache(io = nil)
    f = File.open(io,"wb") if io
    @cache = Hash.new
    $data_routes.each do |key, value|
      table = Table.new(value[4].size,value[3]+1,2)
      value[4].each do |s|
        (0..value[3]).each do |w|
          eval("table[s,w,0]="+value[1])
          eval("table[s,w,1]="+value[2])
        end
      end
      @cache[key] = [value[0],table]
    end
    Marshal.dump(@cache,f) if io
    f.close if io
    @cache.each{|key, value|@cache[key] = [Bitmap.new(value[0]),value[1]]}
  end
  def loademitter(w)
    f=File.open(w,"rb");@emitter=Marshal.load(f);f.close
  end
  def makeemitter(io)
    f = File.open(io,"wb") if io
    @emitter = $data_emitter
    Marshal.dump(@emitter,f) if io
    f.close if io
  end
end
$hcl = HCl.new
class Game_Map
  if @self_alias == nil;alias self_update update;@self_alias = true;end
  def update;$hcl.update;self_update;end
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
      $hcl.bullets.each{|w|w.stdy = w.stdy - distance/4}
      @display_y = @display_y + distance
    else
      $hcl.bullets.each{|w|w.stdy = w.stdy - (distance-d)/4}
      @display_y = (self.height - 15) * 128
    end
  end
  def scroll_left(distance)
    d = @display_x - distance
    if d >= 0
      $hcl.bullets.each{|w|w.stdx = w.stdx + distance/4}
      @display_x = @display_x - distance
    else
      $hcl.bullets.each{|w|w.stdx = w.stdx - @display_x/4}
      @display_x = 0
    end
  end
  def scroll_right(distance)
    d = @display_x + distance - (self.width - 20) * 128
    if d <= 0
      $hcl.bullets.each{|w|w.stdx = w.stdx - distance/4}
      @display_x = @display_x + distance
    else
      $hcl.bullets.each{|w|w.stdx = w.stdx - (distance-d)/4}
      @display_x = (self.width - 20) * 128
    end
  end
  def scroll_up(distance)
    d = @display_y - distance
    if d >= 0
      $hcl.bullets.each{|w|w.stdy = w.stdy + distance/4}
      @display_y = @display_y - distance
    else
      $hcl.bullets.each{|w|w.stdy = w.stdy - @display_y/4}
      @display_y = 0
    end
  end
end
class Scene_Map    ;attr_accessor :spriteset;end
class Spriteset_Map;attr_accessor :viewport1;end
class Game_Event   ;attr_accessor :id       ;end
class Game_Player
  def update
    unless $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      case Input.dir4
      when 2
        $game_map.scroll_down(4)
      when 4
        $game_map.scroll_left(4)
      when 6
        $game_map.scroll_right(4)
      when 8
        $game_map.scroll_up(4)
      end
      if Input.trigger?(Input::C)
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
      if Input.press?(Input::A)
        if $hcl.imp(1)
          $hcl.fire(screen_x,screen_y,"origin",270,0)
          $hcl.fire(screen_x-2,screen_y,"origin",270,0)
          $hcl.fire(screen_x+2,screen_y,"origin",270,0)
        end
      end
    end
    a,b = Mouse.pos
    @real_x = (a - 16) * 4 - 3 + $game_map.display_x
    @real_y = (b - 32) * 4 - 3 + $game_map.display_y
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
