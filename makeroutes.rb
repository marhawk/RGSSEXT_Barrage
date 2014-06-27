$data_routes = {
  "origin" => ["Graphics/Particles/0.png",
  "((0.001*(w-50)**3+125)*Math.cos(Math::PI*s/180)).to_i",
  "((0.001*(w-50)**3+125)*Math.sin(Math::PI*s/180)).to_i",
  150,
  (0..360).to_a,
               ],
  
  "inverted" => ["Graphics/Particles/1.png",
 "((0.001*(w-50)**3+125)*Math.cos(Math::PI*s/180)).to_i",
  "((0.001*(w-50)**3+125)*Math.sin(Math::PI*s/180)).to_i",
  150,
  (0..360).to_a,
                 ],

}
$data_emitter = {
  "circle" => "(0..360).each{|s|self.fire(%d,%d,route,s,standpoint)}",
  "circle_std" => "(0..30).each{|s|self.fire(%d,%d,route,s*12,standpoint)}",

}

HCL.makecache("Data/Routes.rxdata")
# Run makecache only when $data_routes is changed
HCL.loadcache("Data/Routes.rxdata")

HCL.makeemitter("Data/Emitter.rxdata")
# Run makeemitter only when $data_emitter is changed
HCL.loademitter("Data/Emitter.rxdata")
