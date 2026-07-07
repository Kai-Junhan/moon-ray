///|
/// Pseudo-random number generation for Monte Carlo rendering.

struct Rng {
  state0 : UInt64
  state1 : UInt64
}

/// Create a new RNG with the given seed.
pub fn new_rng(seed : UInt64) -> Rng {
  let s0 = splitmix64(seed)
  let s1 = splitmix64(s0)
  { state0: s0, state1: s1 }
}

/// Create a new RNG with a default seed.
pub fn default_rng() -> Rng {
  new_rng(123456789UL)
}

fn splitmix64(state : UInt64) -> UInt64 {
  let mut z = state + 0x9e3779b97f4a7c15UL
  z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9UL
  z = (z ^ (z >> 27)) * 0x94d049bb133111ebUL
  z ^ (z >> 31)
}

fn Rng::next_u64(self : Rng) -> (UInt64, Rng) {
  let s1 = self.state0
  let s0 = self.state1
  let result = s0 + s1
  let new_state0 = s0
  let mut new_s1 = s1 ^ (s1 << 23)
  new_s1 = new_s1 ^ (new_s1 >> 17)
  new_s1 = new_s1 ^ s0
  new_s1 = new_s1 ^ (s0 >> 26)
  (result, { state0: new_state0, state1: new_s1 })
}

/// Generate a random Double in [0, 1).
pub fn Rng::random_double(self : Rng) -> (Double, Rng) {
  let (val, new_rng) = self.next_u64()
  (val.to_double() / 18446744073709551616.0, new_rng)
}

/// Generate a random Double in [min, max).
pub fn Rng::random_double_range(self : Rng, min~ : Double, max~ : Double) -> (Double, Rng) {
  let (val, new_rng) = self.random_double()
  (min + (max - min) * val, new_rng)
}

/// Generate a random integer in [0, n).
pub fn Rng::random_int(self : Rng, n : Int) -> (Int, Rng) {
  let (val, new_rng) = self.random_double()
  let i = (val * n.to_double()).to_int()
  (if i >= n { n - 1 } else { i }, new_rng)
}

/// Generate a random point inside the unit sphere (recursive rejection sampling).
pub fn Rng::random_in_unit_sphere(self : Rng) -> (Vec3, Rng) {
  let (x, rng1) = self.random_double_range(min=-1.0, max=1.0)
  let (y, rng2) = rng1.random_double_range(min=-1.0, max=1.0)
  let (z, rng3) = rng2.random_double_range(min=-1.0, max=1.0)
  let p = { x, y, z }
  if p.length_squared() < 1.0 {
    (p, rng3)
  } else {
    rng3.random_in_unit_sphere()
  }
}

/// Generate a random unit vector (on the unit sphere surface, uniform).
pub fn Rng::random_unit_vector(self : Rng) -> (Vec3, Rng) {
  let (p, new_rng) = self.random_in_unit_sphere()
  (p.normalize(), new_rng)
}

/// Generate a random point on the hemisphere oriented by the given normal.
pub fn Rng::random_on_hemisphere(self : Rng, normal : Vec3) -> (Vec3, Rng) {
  let (p, new_rng) = self.random_in_unit_sphere()
  if p.dot(normal) > 0.0 {
    (p, new_rng)
  } else {
    (-p, new_rng)
  }
}

/// Generate a random point inside the unit disk (for defocus blur).
pub fn Rng::random_in_unit_disk(self : Rng) -> (Vec3, Rng) {
  let (x, rng1) = self.random_double_range(min=-1.0, max=1.0)
  let (y, rng2) = rng1.random_double_range(min=-1.0, max=1.0)
  let p = { x, y, z: 0.0 }
  if p.length_squared() < 1.0 {
    (p, rng2)
  } else {
    rng2.random_in_unit_disk()
  }
}

/// Cosine-weighted hemisphere sampling (Lambertian).
pub fn Rng::random_cosine_direction(self : Rng) -> (Vec3, Rng) {
  let (r1, rng1) = self.random_double()
  let (r2, rng2) = rng1.random_double()
  let z = (1.0 - r2).sqrt()
  let phi = 2.0 * @math.PI * r1
  let x = @math.cos(phi) * r2.sqrt()
  let y = @math.sin(phi) * r2.sqrt()
  ({ x, y, z }, rng2)
}
