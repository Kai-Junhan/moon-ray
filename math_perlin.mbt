///|
/// Perlin noise generator for procedural texturing.

pub(all) struct Perlin {
  randfloat : Array[Double]
  perm_x : Array[Int]
  perm_y : Array[Int]
  perm_z : Array[Int]
} derive(Debug)

pub fn Perlin::new() -> Perlin {
  let point_count = 256
  let randfloat = Array::new(capacity=point_count)
  for _ in 0..<point_count {
    let rng = default_rng()
    let (v, _) = rng.random_double()
    randfloat.push(v)
  }

  let perm_x = perlin_generate_perm()
  let perm_y = perlin_generate_perm()
  let perm_z = perlin_generate_perm()

  { randfloat, perm_x, perm_y, perm_z }
}

fn perlin_generate_perm() -> Array[Int] {
  let p = Array::new(capacity=256)
  for i in 0..<256 {
    p.push(i)
  }
  perlin_permute(p)
  p
}

fn perlin_permute(p : Array[Int]) -> Unit {
  let mut i = p.length() - 1
  while i >= 1 {
    let target = default_rng().random_int(i + 1).0
    let tmp = p[i]
    p[i] = p[target]
    p[target] = tmp
    i = i - 1
  }
}

fn Perlin::perm_index(self : Perlin, i : Int, j : Int, k : Int) -> Int {
  let xi = i & 255
  let yi = j & 255
  let zi = k & 255
  self.perm_x[xi] ^ self.perm_y[yi] ^ self.perm_z[zi]
}

fn trilinear_interp(c000 : Double, c001 : Double, c010 : Double, c011 : Double,
                    c100 : Double, c101 : Double, c110 : Double, c111 : Double,
                    u : Double, v : Double, w : Double) -> Double {
  let uu = u * u * (3.0 - 2.0 * u)
  let vv = v * v * (3.0 - 2.0 * v)
  let ww = w * w * (3.0 - 2.0 * w)

  let x00 = c000 + uu * (c100 - c000)
  let x01 = c001 + uu * (c101 - c001)
  let x10 = c010 + uu * (c110 - c010)
  let x11 = c011 + uu * (c111 - c011)

  let y0 = x00 + vv * (x10 - x00)
  let y1 = x01 + vv * (x11 - x01)

  y0 + ww * (y1 - y0)
}

fn Perlin::noise(self : Perlin, p : Vec3) -> Double {
  let u = p.x - p.x.floor()
  let v = p.y - p.y.floor()
  let w = p.z - p.z.floor()

  let i = p.x.floor().to_int()
  let j = p.y.floor().to_int()
  let k = p.z.floor().to_int()

  let corner_values = Array::new(capacity=8)

  for di in 0..<2 {
    for dj in 0..<2 {
      for dk in 0..<2 {
        let idx = self.randfloat[self.perm_index(i + di, j + dj, k + dk) % 256]
        corner_values.push(idx)
      }
    }
  }

  trilinear_interp(
    corner_values[0], corner_values[1], corner_values[2], corner_values[3],
    corner_values[4], corner_values[5], corner_values[6], corner_values[7],
    u, v, w,
  )
}

pub fn Perlin::turbulence(self : Perlin, p : Vec3, depth~ : Int) -> Double {
  let mut accum = 0.0
  let mut temp_p = p
  let mut weight = 1.0

  for _ in 0..<depth {
    accum = accum + weight * self.noise(temp_p)
    weight = weight * 0.5
    temp_p = temp_p.mul_scalar(2.0)
  }

  accum.abs()
}
