///|
/// Texture system using enum dispatch.
/// Textures map surface coordinates (u, v) and hit points to colors.

pub(all) enum Texture {
  Solid(Vec3)
  Checker(Texture, Texture, Double)
  Noise(Double)
  Image(Array[Vec3], Int, Int)
} derive(Debug)

pub fn Texture::solid(color~ : Vec3) -> Texture {
  Solid(color)
}

pub fn Texture::checker(even~ : Texture, odd~ : Texture, scale~ : Double) -> Texture {
  Checker(even, odd, scale)
}

pub fn Texture::noise(scale~ : Double) -> Texture {
  Noise(scale)
}

pub fn Texture::value(self : Texture, u : Double, v : Double, p : Vec3) -> Vec3 {
  match self {
    Solid(color) => color
    Checker(even, odd, scale) => {
      let sines = @math.sin(scale * p.x) * @math.sin(scale * p.y) * @math.sin(scale * p.z)
      if sines < 0.0 {
        odd.value(u, v, p)
      } else {
        even.value(u, v, p)
      }
    }
    Noise(scale) => {
      let s = scale
      let i = ((s * p.x).floor() + (s * p.y).floor() + (s * p.z).floor()).to_int()
      let r = hash_int(i, 0)
      let g = hash_int(i, 1)
      let b = hash_int(i, 2)
      {
        x: r.to_double() / 255.0,
        y: g.to_double() / 255.0,
        z: b.to_double() / 255.0,
      }
    }
    Image(data, width, height) => {
      let i = (u * width.to_double()).to_int()
      let j = ((1.0 - v) * height.to_double()).to_int()
      let ui = if i < 0 { 0 } else if i >= width { width - 1 } else { i }
      let vj = if j < 0 { 0 } else if j >= height { height - 1 } else { j }
      data[vj * width + ui]
    }
  }
}

fn hash_int(n : Int, seed : Int) -> Int {
  let mut h = n * 374761393 + seed * 668265263
  h = (h ^ (h >> 13)) * 1274126177
  h = h ^ (h >> 16)
  ((h % 256) + 256) % 256
}
