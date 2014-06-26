$data_routes = {
  "origin" => ["Graphics/Particles/0.png",
  "((0.0001*(w-150)**3+337.5)*Math.cos(Math::PI*s/180)).to_i",
  "((0.0001*(w-150)**3+337.5)*Math.sin(Math::PI*s/180)).to_i",
  300
             ],
  
  "inverted" => ["Graphics/Particles/1.png",
  "0",
  "0",
  300
             ],

}
HCL.makecache("Data/Routes.rxdata")
HCL.loadcache("Data/Routes.rxdata")
