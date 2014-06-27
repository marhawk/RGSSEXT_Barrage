$data_routes = {
  "origin" => ["Graphics/Particles/0.png",
  "((0.0001*(w-150)**3+337.5)*Math.cos(Math::PI*s/180)).to_i",
  "((0.0001*(w-150)**3+337.5)*Math.sin(Math::PI*s/180)).to_i",
  300,
  (0..360).to_a,
             ],
  
  "inverted" => ["Graphics/Particles/1.png",
 "((0.0001*(w-150)**3+337.5)*Math.cos(Math::PI*s/180)).to_i",
  "((0.0001*(w-150)**3+337.5)*Math.sin(Math::PI*s/180)).to_i",
  300,
  (0..360).to_a,
             ],

}
$data_emitter = {
  "origin" => [
  [],
             ],
  
  "inverted" => [
  [],
             ],

}
HCL.makecache("Data/Routes.rxdata")
HCL.loadcache("Data/Routes.rxdata")
