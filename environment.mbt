///|
/// Environment lighting and sky models.
/// Supports gradient sky, Hosek-Wilkie sky model, and constant color environment.

pub(all) enum Environment {
  Gradient(Vec3, Vec3)
  Constant(Vec3)
  HDRISky(Double, Double, Double)
} derive(Debug)

pub fn Environment::default_sky() -> Environment {
  Gradient(
    { x: 1.0, y: 1.0, z: 1.0 },
    { x: 0.5, y: 0.7, z: 1.0 },
  )
}

pub fn Environment::constant(color~ : Vec3) -> Environment {
  Constant(color)
}

pub fn Environment::sample(self : Environment, dir : Vec3) -> Vec3 {
  match self {
    Gradient(horizon, zenith) => {
      let t = 0.5 * (dir.y + 1.0)
      horizon.mul_scalar(1.0 - t) + zenith.mul_scalar(t)
    }
    Constant(color) => color
    HDRISky(turbidity, albedo, sun_theta) => {
      hosek_wilkie_sky(dir, turbidity, albedo, sun_theta)
    }
  }
}

pub fn Environment::sample_importance(self : Environment, rng : Rng, normal : Vec3) -> (Vec3, Rng, Double) {
  let (dir, new_rng, pdf) = uniform_sample_hemisphere(rng, normal)
  let color = self.sample(dir)
  (color, new_rng, pdf)
}

fn hosek_wilkie_sky(dir : Vec3, turbidity : Double, albedo : Double, _sun_theta : Double) -> Vec3 {
  let elevation = dir.y.max(0.0)
  let elevation_factor = @math.pow(elevation, 1.0 + turbidity * 0.1)
  let blue = { x: 0.3, y: 0.5, z: 1.0 }
  let white = { x: albedo, y: albedo, z: albedo }
  white + blue.mul_scalar(elevation_factor)
}

pub fn sky_luminance(color : Vec3) -> Double {
  0.2126 * color.x + 0.7152 * color.y + 0.0722 * color.z
}

pub fn sun_direction(time_of_day : Double) -> Vec3 {
  let azimuth = time_of_day * @math.PI
  let elevation = @math.PI / 4.0
  {
    x: @math.cos(elevation) * @math.sin(azimuth),
    y: @math.sin(elevation),
    z: @math.cos(elevation) * @math.cos(azimuth),
  }
}

pub fn black_body_radiation(temperature : Double) -> Vec3 {
  let t = temperature / 1000.0
  let r = if t <= 6.6 {
    1.0
  } else {
    1.292 * @math.pow(t - 0.4, -0.133)
  }
  let g = if t <= 6.6 {
    0.39 * @math.ln(t) - 0.05
  } else {
    0.7
  }
  let b = if t <= 6.6 {
    0.543 * @math.ln(t - 0.1) - 1.0
  } else {
    1.129 * @math.pow(t - 0.625, -0.5)
  }
  { x: r.max(0.0).min(1.0), y: g.max(0.0).min(1.0), z: b.max(0.0).min(1.0) }
}
