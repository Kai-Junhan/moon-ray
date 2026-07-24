///|
/// Monte Carlo Path Tracing renderer.
/// BVH, Russian roulette, NEE, volume fog, and post-processing
/// are fully integrated into the rendering pipeline.

/// Background sky.
fn background_sky(r : Ray) -> Vec3 {
  let unit_dir = r.dir.normalize()
  let t = 0.5 * (unit_dir.y + 1.0)
  let white = Vec3::new(x=1.0, y=1.0, z=1.0)
  let blue = Vec3::new(x=0.5, y=0.7, z=1.0)
  white.mul_scalar(1.0 - t) + blue.mul_scalar(t)
}

/// Find all emissive objects in the scene and sample one randomly.
fn sample_scene_lights(world : HitableList, rng : Rng) -> (Vec3, Vec3, Double, Rng) {
  let mut light_count = 0
  for i in 0..<world.objects.length() {
    let emitted = world.objects[i].match_material(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
    if emitted.length() > 0.001 { light_count = light_count + 1 }
  }
  if light_count == 0 {
    return (Vec3::new(x=0.0, y=0.0, z=0.0), Vec3::new(x=0.0, y=0.0, z=0.0), 0.0, rng)
  }
  let (li, r1) = rng.random_int(light_count)
  let mut lidx = 0
  let mut light_pos = Vec3::new(x=0.0, y=0.0, z=0.0)
  let mut light_color = Vec3::new(x=0.0, y=0.0, z=0.0)
  for i in 0..<world.objects.length() {
    let emitted = world.objects[i].match_material(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
    if emitted.length() > 0.001 {
      if lidx == li {
        let bbox = world.objects[i].bounding_box()
        light_pos = Vec3::new(x=(bbox.min.x + bbox.max.x) * 0.5, y=(bbox.min.y + bbox.max.y) * 0.5, z=(bbox.min.z + bbox.max.z) * 0.5)
        light_color = emitted
        break
      }
      lidx = lidx + 1
    }
  }
  (light_pos, light_color, light_count.to_double(), r1)
}

pub fn Hitable::match_material(self : Hitable, u : Double, v : Double, p : Vec3) -> Vec3 {
  match self {
    Sphere(s) => s.material.emitted(u, v, p)
    Plane(pl) => pl.material.emitted(u, v, p)
    Triangle(tri) => tri.material.emitted(u, v, p)
    BoxShape(bx) => bx.material.emitted(u, v, p)
    Cylinder(cyl) => cyl.material.emitted(u, v, p)
    Disk(dk) => dk.material.emitted(u, v, p)
    Cone(cn) => cn.material.emitted(u, v, p)
    Torus(tor) => tor.material.emitted(u, v, p)
  }
}

pub fn Material::albedo_at(self : Material, u : Double, v : Double, p : Vec3) -> Vec3 {
  match self {
    Lambertian(a) => a
    Metal(a, _) => a
    Dielectric(_) => Vec3::new(x=1.0, y=1.0, z=1.0)
    Emissive(c) => c
    DiffuseLight(t) => t.value(u, v, p)
    Isotropic(a) => a
    Textured(t) => t.value(u, v, p)
  }
}

/// Core recursive ray tracer with NEE, Russian roulette, and volume fog.
fn ray_color(
  r : Ray,
  world : HitableList,
  depth : Int,
  rng : Rng,
  fog_enabled : Bool,
  fog_density : Double,
  fog_color : Vec3
) -> (Vec3, Rng) {
  if depth <= 0 {
    return (Vec3::new(x=0.0, y=0.0, z=0.0), rng)
  }

  let hit = world.hit(r, t_min=0.001, t_max=1.0e30)
  match hit {
    None => {
      let sky = background_sky(r)
      if fog_enabled { (exponential_fog(sky, 1000.0, fog_density, fog_color), rng) } else { (sky, rng) }
    }
    Some(rec) => {
      let mut color = Vec3::new(x=0.0, y=0.0, z=0.0)
      let mut rng_out = rng

      // NEE with MIS: sample emissive lights at each hit point
      let (light_pos, light_color, light_count, r1) = sample_scene_lights(world, rng_out)
      rng_out = r1
      if light_count > 0.5 && light_color.length() > 0.01 {
        let to_light = light_pos - rec.p
        let dist_sq = to_light.length_squared()
        let dist = dist_sq.sqrt()
        let light_dir = to_light.div_scalar(dist)
        let shadow_ray = Ray::new(orig=rec.p, dir=light_dir)
        let shadow = world.hit(shadow_ray, t_min=0.001, t_max=dist)
        match shadow {
          None => {
            let ndotl = rec.normal.dot(light_dir).max(0.0)
            let bsdf = rec.material.albedo_at(0.0, 0.0, rec.p).mul_scalar(1.0 / @math.PI)
            let light_pdf = dist_sq * light_count
            let bsdf_pdf = ndotl / @math.PI
            let mis_weight = power_heuristic(1.0, 1.0 / light_pdf, 1.0, bsdf_pdf, beta=2.0)
            color = color + bsdf * light_color.mul_scalar(ndotl * mis_weight / (dist_sq * light_count))
          }
          Some(_) => ()
        }
      }

      // Emission from the hit surface itself
      let emitted = rec.material.emitted(0.0, 0.0, rec.p)
      color = color + emitted

      // Indirect bounce
      let scatter = rec.material.scatter(r, rec)
      match scatter {
        None => {
          if fog_enabled { (exponential_fog(color, rec.t, fog_density, fog_color), rng_out) } else { (color, rng_out) }
        }
        Some(s) => {
          // Russian roulette for depths > 3
          let (rand_val, rr_rng) = rng_out.random_double()
          rng_out = rr_rng
          let max_comp = s.attenuation.x.max(s.attenuation.y).max(s.attenuation.z)
          let prob = if depth <= 3 { 1.0 } else { (max_comp * 0.7).min(0.95) }
          if rand_val < prob {
            let (indirect, r2) = ray_color(s.scattered, world, depth - 1, rng_out, fog_enabled, fog_density, fog_color)
            rng_out = r2
            let indirect_mis = if light_count > 0.5 {
              let cos_theta = rec.normal.dot(s.scattered.dir.normalize()).abs()
              let bsdf_pdf = cos_theta / @math.PI
              balanced_heuristic(1.0, bsdf_pdf, 1.0, 1.0 / (light_count * 4.0 * @math.PI))
            } else {
              1.0
            }
            color = color + s.attenuation.mul_scalar(indirect_mis / prob) * indirect
          }
          if fog_enabled { (exponential_fog(color, rec.t, fog_density, fog_color), rng_out) } else { (color, rng_out) }
        }
      }
    }
  }
}

/// Render with BVH acceleration, NEE, Russian roulette, and optional volume fog.
pub fn render_scene(
  width~ : Int, height~ : Int,
  samples_per_pixel~ : Int, max_depth~ : Int,
  world~ : HitableList, cam~ : Camera,
  fog_density~ : Double
) -> Array[Vec3] {
  let processed = world.build_bvh()
  let fog_on = fog_density > 0.0
  let fog_color = Vec3::new(x=0.7, y=0.8, z=0.9)
  let size = width * height
  let pixels = Array::new(capacity=size)

  for j in 0..<height {
    for i in 0..<width {
      let mut color = Vec3::new(x=0.0, y=0.0, z=0.0)
      let mut rng = default_rng()
      for _ in 0..<samples_per_pixel {
        let (u, r1) = rng.random_double()
        let (v, r2) = r1.random_double()
        rng = r2
        let s = (i.to_double() + u) / width.to_double()
        let t = ((height - 1 - j).to_double() + v) / height.to_double()
        let ray = cam.get_ray(s, t)
        let (c, r3) = ray_color(ray, processed, max_depth, rng, fog_on, fog_density, fog_color)
        rng = r3
        color = color + c
      }
      pixels.push(color)
    }
  }
  pixels
}

/// Full pipeline: render + ACES tone mapping + bloom + color grading + vignette + gamma.
pub fn render_scene_full(
  width~ : Int, height~ : Int,
  samples_per_pixel~ : Int, max_depth~ : Int,
  world~ : HitableList, cam~ : Camera,
  fog_density~ : Double,
  post_process~ : PostProcessConfig
) -> Array[Vec3] {
  let raw = render_scene(width=width, height=height, samples_per_pixel=samples_per_pixel, max_depth=max_depth, world=world, cam=cam, fog_density=fog_density)
  let scale = 1.0 / samples_per_pixel.to_double()

  // Scale and tone map
  let toned = Array::new(capacity=raw.length())
  for idx in 0..<raw.length() {
    let pixel = raw[idx].mul_scalar(scale)
    let a = 2.51; let b = 0.03; let c = 2.43; let d = 0.59; let e = 0.14
    let tonemap = fn(comp : Double) -> Double {
      let num = comp * (comp * a + b)
      let den = comp * (comp * c + d) + e
      (num / den).clamp(min=0.0, max=1.0)
    }
    toned.push(Vec3::new(x=tonemap(pixel.x), y=tonemap(pixel.y), z=tonemap(pixel.z)))
  }

  // Bloom
  let after_bloom = if post_process.bloom_enabled {
    apply_bloom(toned, width, height, threshold=post_process.bloom_threshold, intensity=post_process.bloom_intensity)
  } else {
    toned
  }

  // Color grading
  let after_grading = if post_process.color_grading_enabled {
    apply_color_grading(after_bloom, width, height, contrast=post_process.contrast, saturation=post_process.saturation, brightness=post_process.brightness, temperature=post_process.temperature)
  } else {
    after_bloom
  }

  // Vignette + gamma
  let cx = width.to_double() * 0.5
  let cy = height.to_double() * 0.5
  let max_r = (cx * cx + cy * cy).sqrt()

  let result = Array::new(capacity=after_grading.length())
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let pixel = after_grading[idx]

      // Vignette
      let dx = (i.to_double() - cx) / max_r
      let dy = (j.to_double() - cy) / max_r
      let dist = (dx * dx + dy * dy).sqrt()
      let vignette = (1.0 - post_process.vignette_strength * dist * dist).max(0.0)
      let pixel_vignette = pixel.mul_scalar(vignette)

      // sRGB gamma
      let gamma = fn(v : Double) -> Double {
        if v <= 0.0031308 { v * 12.92 } else { 1.055 * @math.pow(v.max(0.0), 1.0 / 2.4) - 0.055 }
      }
      let final_pixel = Vec3::new(
        x=gamma(pixel_vignette.x).clamp(min=0.0, max=1.0),
        y=gamma(pixel_vignette.y).clamp(min=0.0, max=1.0),
        z=gamma(pixel_vignette.z).clamp(min=0.0, max=1.0),
      )
      result.push(final_pixel)
    }
  }
  result
}
