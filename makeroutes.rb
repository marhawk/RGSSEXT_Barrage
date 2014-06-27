$data_routes = {
  "origin" => ["Graphics/Particles/0.png",
  "((0.001*(w-50)**3+125)*Math.cos(Math::PI*s/180)).to_i",
  "((0.001*(w-50)**3+125)*Math.sin(Math::PI*s/180)).to_i",
  150,
  (0..360).to_a,
  ["",""],
               ],
  
  "inverted" => ["Graphics/Particles/1.png",
 "((0.001*(w-50)**3+125)*Math.cos(Math::PI*s/180)).to_i",
  "((0.001*(w-50)**3+125)*Math.sin(Math::PI*s/180)).to_i",
  150,
  (0..360).to_a,
  ["",""],
                 ],
  "clockwise" => ["Graphics/Particles/2.png",
  "((0.001*(w-50)**3+125)*Math.cos(Math::PI*s2/180)).to_i",
  "((0.001*(w-50)**3+125)*Math.sin(Math::PI*s2/180)).to_i",
  150,
  (0..360).to_a,
  ["s2=s","s2=(s2+1)%360"],
               ],
  
}
$data_emitter = {
  "circle" => "(0..360).each{|s|fire(%d,%d,route,s,standpoint)}",
  "circle_std" => "(0..30).each{|s|fire(%d,%d,route,s*12,standpoint)}",

}
$hcl.makecache("Data/Routes.rxdata")
$hcl.loadcache("Data/Routes.rxdata")
$hcl.makeemitter("Data/Emitter.rxdata")
$hcl.loademitter("Data/Emitter.rxdata")
