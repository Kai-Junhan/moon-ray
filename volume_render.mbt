///|
/// Participating media (volume rendering) support.
/// Simulates fog, smoke, and volumetric scattering through ray marching.

pub(all) struct VolumeBox {
  min_point : Vec3
  max_point : Vec3
  density : Double
  albedo : Vec3
} derive(Debug)

pub fn VolumeBox::new(min_point~ : Vec3, max_point~ : Vec3, density~ : Double, albedo~ : Vec3) -> VolumeBox {
  { min_point, max_point, density, albedo }
}

fn constant_medium_aabb(vol : VolumeBox) -> AABB {
  { min: vol.min_point, max: vol.max_point }
}

pub fn ray_march_volume(
  vol : VolumeBox,
  r : Ray,
  t_min : Double,
  t_max : Double
) -> (Vec3, Double) {
  let aabb = constant_medium_aabb(vol)
  if !(aabb.hit(r, t_min=t_min, t_max=t_max)) {
    return ({ x: 0.0, y: 0.0, z: 0.0 }, 1.0)
  }

  let inv_dir = { x: 1.0 / r.dir.x, y: 1.0 / r.dir.y, z: 1.0 / r.dir.z }
  let t0 = (vol.min_point.x - r.orig.x) * inv_dir.x
  let t1 = (vol.max_point.x - r.orig.x) * inv_dir.x
  let mut t_entry = if inv_dir.x > 0.0 { t0 } else { t1 }
  let mut t_exit = if inv_dir.x > 0.0 { t1 } else { t0 }

  let ty0 = (vol.min_point.y - r.orig.y) * inv_dir.y
  let ty1 = (vol.max_point.y - r.orig.y) * inv_dir.y
  let tymin = if inv_dir.y > 0.0 { ty0 } else { ty1 }
  let tymax = if inv_dir.y > 0.0 { ty1 } else { ty0 }
  t_entry = t_entry.max(tymin)
  t_exit = t_exit.min(tymax)

  let tz0 = (vol.min_point.z - r.orig.z) * inv_dir.z
  let tz1 = (vol.max_point.z - r.orig.z) * inv_dir.z
  let tzmin = if inv_dir.z > 0.0 { tz0 } else { tz1 }
  let tzmax = if inv_dir.z > 0.0 { tz1 } else { tz0 }
  t_entry = t_entry.max(tzmin)
  t_exit = t_exit.min(tzmax)

  t_entry = t_entry.max(t_min)
  t_exit = t_exit.min(t_max)

  if t_entry >= t_exit {
    return ({ x: 0.0, y: 0.0, z: 0.0 }, 1.0)
  }

  let dist_inside = t_exit - t_entry
  let optical_depth = dist_inside * vol.density
  let transmittance = @math.exp(-optical_depth)

  let emitted = vol.albedo.mul_scalar(1.0 - transmittance)
  (emitted, transmittance)
}

pub fn exponential_fog(
  color : Vec3,
  dist : Double,
  fog_density : Double,
  fog_color : Vec3
) -> Vec3 {
  let transmittance = @math.exp(-dist * fog_density)
  color.mul_scalar(transmittance) + fog_color.mul_scalar(1.0 - transmittance)
}

pub fn layered_fog(
  color : Vec3,
  pos_y : Double,
  fog_base : Double,
  fog_top : Double,
  fog_density : Double,
  fog_color : Vec3
) -> Vec3 {
  let height_factor = ((pos_y - fog_base) / (fog_top - fog_base)).clamp(min=0.0, max=0.999)
  let density = fog_density * (1.0 - height_factor)
  let transmittance = @math.exp(-density)
  color.mul_scalar(transmittance) + fog_color.mul_scalar(1.0 - transmittance)
}

pub fn beer_lambert_absorption(color : Vec3, dist : Double, density : Vec3) -> Vec3 {
  {
    x: color.x * @math.exp(-dist * density.x),
    y: color.y * @math.exp(-dist * density.y),
    z: color.z * @math.exp(-dist * density.z),
  }
}
