///|
/// Tone mapping and color space utilities.
/// Implements Reinhard, ACES, and filmic tone mapping operators.

pub fn reinhard_tone_map(color : Vec3) -> Vec3 {
  let denom = {
    x: color.x + 1.0,
    y: color.y + 1.0,
    z: color.z + 1.0,
  }
  { x: color.x / denom.x, y: color.y / denom.y, z: color.z / denom.z }
}

pub fn aces_tone_map(color : Vec3) -> Vec3 {
  let a = 2.51
  let b = 0.03
  let c = 2.43
  let d = 0.59
  let e = 0.14
  let num_x = color.x * (color.x * a + b)
  let den_x = color.x * (color.x * c + d) + e
  let num_y = color.y * (color.y * a + b)
  let den_y = color.y * (color.y * c + d) + e
  let num_z = color.z * (color.z * a + b)
  let den_z = color.z * (color.z * c + d) + e
  { x: (num_x / den_x).clamp(min=0.0, max=0.999),
    y: (num_y / den_y).clamp(min=0.0, max=0.999),
    z: (num_z / den_z).clamp(min=0.0, max=0.999) }
}

pub fn exposure_adjust(color : Vec3, exposure : Double) -> Vec3 {
  let exp_factor = @math.pow(2.0, exposure)
  color.mul_scalar(exp_factor)
}

pub fn gamma_correct(color : Vec3, gamma : Double) -> Vec3 {
  {
    x: @math.pow(color.x.max(0.0), 1.0 / gamma),
    y: @math.pow(color.y.max(0.0), 1.0 / gamma),
    z: @math.pow(color.z.max(0.0), 1.0 / gamma),
  }
}

pub fn srgb_gamma_correct(color : Vec3) -> Vec3 {
  let r = if color.x <= 0.0031308 {
    color.x * 12.92
  } else {
    1.055 * @math.pow(color.x.max(0.0), 1.0 / 2.4) - 0.055
  }
  let g = if color.y <= 0.0031308 {
    color.y * 12.92
  } else {
    1.055 * @math.pow(color.y.max(0.0), 1.0 / 2.4) - 0.055
  }
  let b = if color.z <= 0.0031308 {
    color.z * 12.92
  } else {
    1.055 * @math.pow(color.z.max(0.0), 1.0 / 2.4) - 0.055
  }
  { x: r.clamp(min=0.0, max=0.999), y: g.clamp(min=0.0, max=0.999), z: b.clamp(min=0.0, max=0.999) }
}
