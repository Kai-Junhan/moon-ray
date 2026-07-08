///|
/// Material system for ray tracing using an enum to dispatch on material type.

pub(all) enum Material {
  Lambertian(Vec3)      // albedo color
  Metal(Vec3, Double)   // albedo, fuzz
  Dielectric(Double)    // index of refraction
  Emissive(Vec3)        // emitted color
  DiffuseLight(Texture) // area light with texture
  Isotropic(Vec3)       // isotropic volume scattering
  Textured(Texture)     // textured dull material
} derive(Debug)

/// Result of a ray scattering off a material.
pub(all) struct ScatterResult {
  attenuation : Vec3
  scattered : Ray
} derive(Debug)

/// Scatter a ray off a material.
pub fn Material::scatter(self : Material, r_in : Ray, rec : HitRecord) -> ScatterResult? {
  match self {
    Lambertian(albedo) => {
      let mut scatter_dir = rec.normal + default_rng().random_unit_vector().0
      if scatter_dir.near_zero() {
        scatter_dir = rec.normal
      }
      let scattered = Ray::new(orig=rec.p, dir=scatter_dir)
      Some({ attenuation: albedo, scattered })
    }
    Metal(albedo, fuzz) => {
      let reflected = reflect(r_in.dir.normalize(), rec.normal)
      let fuzz_offset = default_rng().random_in_unit_sphere().0
      let scattered_dir = reflected + fuzz_offset.mul_scalar(fuzz)
      let scattered = Ray::new(orig=rec.p, dir=scattered_dir)
      if scattered.dir.dot(rec.normal) > 0.0 {
        Some({ attenuation: albedo, scattered })
      } else {
        None
      }
    }
    Dielectric(ir) => {
      let attenuation = { x: 1.0, y: 1.0, z: 1.0 }
      let refraction_ratio = if rec.front_face { 1.0 / ir } else { ir }
      let unit_dir = r_in.dir.normalize()
      let cos_theta = (-unit_dir).dot(rec.normal).min(1.0)
      let sin_theta = (1.0 - cos_theta * cos_theta).max(0.0).sqrt()
      let cannot_refract = refraction_ratio * sin_theta > 1.0
      let rand_val = default_rng().random_double().0
      let direction = if cannot_refract || reflectance(cos_theta, refraction_ratio) > rand_val {
        reflect(unit_dir, rec.normal)
      } else {
        match refract(unit_dir, rec.normal, refraction_ratio) {
          None => reflect(unit_dir, rec.normal)
          Some(refracted) => refracted
        }
      }
      let scattered = Ray::new(orig=rec.p, dir=direction)
      Some({ attenuation, scattered })
    }
    Emissive(_color) => None
    DiffuseLight(_tex) => None
    Isotropic(albedo) => {
      let scatter_dir = default_rng().random_unit_vector().0
      let scattered = Ray::new(orig=rec.p, dir=scatter_dir)
      Some({ attenuation: albedo, scattered })
    }
    Textured(tex) => {
      let albedo = tex.value(0.0, 0.0, rec.p)
      let mut scatter_dir = rec.normal + default_rng().random_unit_vector().0
      if scatter_dir.near_zero() {
        scatter_dir = rec.normal
      }
      let scattered = Ray::new(orig=rec.p, dir=scatter_dir)
      Some({ attenuation: albedo, scattered })
    }
  }
}

/// Get emitted light from a material.
pub fn Material::emitted(self : Material, u : Double, v : Double, p : Vec3) -> Vec3 {
  match self {
    Emissive(color) => color
    DiffuseLight(tex) => tex.value(u, v, p)
    _ => { x: 0.0, y: 0.0, z: 0.0 }
  }
}

/// Schlick approximation for reflectance.
fn reflectance(cosine : Double, ref_idx : Double) -> Double {
  let r0 = (1.0 - ref_idx) / (1.0 + ref_idx)
  let r02 = r0 * r0
  r02 + (1.0 - r02) * @math.pow(1.0 - cosine, 5.0)
}
