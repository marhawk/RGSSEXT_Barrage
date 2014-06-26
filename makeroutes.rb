$data_routes = {
  "origin_2" => ["Graphics/Particles/0.png",
  "0",
  "(0.0001*(w-150)**3+337.5).to_i",
  300
             ],
  "origin_4" => ["Graphics/Particles/0.png",
  "-(0.0001*(w-150)**3+337.5).to_i",
  "0",
  300
             ],
  "origin_6" => ["Graphics/Particles/0.png",
  "(0.0001*(w-150)**3+337.5).to_i",
  "0",
  300
             ],
  "origin_8" => ["Graphics/Particles/0.png",
  "0",
  "-(0.0001*(w-150)**3+337.5).to_i",
  300
             ],
  "inverted_2" => ["Graphics/Particles/1.png",
  "0",
  "(0.0001*(w-150)**3+337.5).to_i",
  300
             ],
  "inverted_4" => ["Graphics/Particles/1.png",
  "-(0.0001*(w-150)**3+337.5).to_i",
  "0",
  300
             ],
  "inverted_6" => ["Graphics/Particles/1.png",
  "(0.0001*(w-150)**3+337.5).to_i",
  "0",
  300
             ],
  "inverted_8" => ["Graphics/Particles/1.png",
  "0",
  "-(0.0001*(w-150)**3+337.5).to_i",
  300
             ],
}
HCL.makecache("Data/Routes.rxdata")
HCL.loadcache("Data/Routes.rxdata")
