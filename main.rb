module HCL
  class Particle < RPG::Sprite
    attr_accessor :main_route
    attr_accessor :stdx
    attr_accessor :stdy
    attr_accessor :style
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
  def self.bullets;return @bullet;end
  def self.command_damage(w,event)
    
  end
  def self.superfire(x,y,route,emitter)
    eval(sprintf(@emitter[emitter],x,y))
  end
  def self.fire(x,y,route,style)
    return unless $scene.is_a?(Scene_Map)
    r = @cache[route]
    sprite = HCL::Particle.new($scene.spriteset.viewport1)
    sprite.stdx = sprite.x = x
    sprite.stdy = sprite.y = y
    sprite.bitmap = r[0]
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height
    sprite.main_route = r[1]
    sprite.style = style
    @bullet.push(sprite)
  end
  def self.update
    @bullet = [] if @bullet == nil
    @cursor = Array.new(641){Array.new(481,[])}
    @bullet.each do |w|
      w.update
      d = $game_map.passable2?((w.realx/128.0).round, (w.realy/128.0).round)
      (w.x<0||w.y<0||w.x>640||w.y>480||!d) ? w.dispose : @cursor[w.x][w.y].push(w)
    end
    for event in $game_map.events.values+[$game_player]
      a = event.screen_x
      b = event.screen_y
      w = @cursor[event.screen_x][event.screen_y] unless a<0||a>640||b<0||b>480
      self.command_damage(w,event) if w
    end
    @bullet.delete_if {|w| w.disposed? }
  end
  def self.loadcache(w)
    f=File.open(w,"rb");@cache=Marshal.load(f);f.close
    @cache.each{|key, value|@cache[key] = [Bitmap.new(value[0]),value[1]]}
  end
  def self.makecache(io = nil)
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
  def self.loademitter(w)
    f=File.open(w,"rb");@emitter=Marshal.load(f);f.close
  end
  def self.makeemitter(io)
    f = File.open(io,"wb") if io
    @emitter = $data_emitter
    Marshal.dump(@emitter,f) if io
    f.close if io
  end
end
class Game_Map
  if @self_alias == nil;alias self_update update;@self_alias = true;end
  def update;HCL.update;self_update;end
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
      HCL.bullets.each{|w|w.stdy = w.stdy - distance/4}
      @display_y = @display_y + distance
    else
      HCL.bullets.each{|w|w.stdy = w.stdy - (distance-d)/4}
      @display_y = (self.height - 15) * 128
    end
  end
  def scroll_left(distance)
    d = @display_x - distance
    if d >= 0
      HCL.bullets.each{|w|w.stdx = w.stdx + distance/4}
      @display_x = @display_x - distance
    else
      HCL.bullets.each{|w|w.stdx = w.stdx - @display_x/4}
      @display_x = 0
    end
  end
  def scroll_right(distance)
    d = @display_x + distance - (self.width - 20) * 128
    if d <= 0
      HCL.bullets.each{|w|w.stdx = w.stdx - distance/4}
      @display_x = @display_x + distance
    else
      HCL.bullets.each{|w|w.stdx = w.stdx - (distance-d)/4}
      @display_x = (self.width - 20) * 128
    end
  end
  def scroll_up(distance)
    d = @display_y - distance
    if d >= 0
      HCL.bullets.each{|w|w.stdy = w.stdy + distance/4}
      @display_y = @display_y - distance
    else
      HCL.bullets.each{|w|w.stdy = w.stdy - @display_y/4}
      @display_y = 0
    end
  end
end
class Scene_Map    ;attr_accessor :spriteset;end
class Spriteset_Map;attr_accessor :viewport1;end
class Game_Player
  if @self_alias == nil;alias self_update update;@self_alias = true;end
  def update
    self_update
    if Input.press?(Input::A)
      HCL.fire(screen_x,screen_y,"origin",rand(45)*8)
    end
  end
end
