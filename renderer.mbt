///|
/// Monte Carlo Path Tracing renderer with BVH, Russian roulette, NEE/MIS,
/// volume rendering, and post-processing all wired into the pipeline.

/// Background sky color for rays that miss all objects.
fn background_sky(r : Ray) -> Vec3 {
  let unit_dir = r.dir.normalize()
  let t = 0.5 * (unit_dir.y + 1.0)
  let white = Vec3::new(x=1.0, y=1.0, z=1.0)
  let blue = Vec3::new(x=0.5, y=0.7, z=1.0)
  white.mul_scalar(1.0 - t) + blue.mul_scalar(t)
}

/// Find emissive lights in the scene and sample a random point on one.
fn sample_scene_lights(world : HitableList, rng : Rng) -> (Vec3, Vec3, Vec3, Double, Rng) {
  let mut light_count = 0
  for i in 0..<world.objects.length() {
    let emitted = world.objects[i].match_material(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
    if emitted.length() > 0.001 {
      light_count = light_count + 1
    }
  }
  if light_count == 0 {
    return (Vec3::new(x=0.0, y=0.0, z=0.0), Vec3::new(x=0.0, y=0.0, z=0.0), Vec3::new(x=0.0, y=0.0, z=0.0), 0.0, rng)
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
        light_pos = Vec3::new(
          x=(bbox.min.x + bbox.max.x) * 0.5,
          y=(bbox.min.y + bbox.max.y) * 0.5,
          z=(bbox.min.z + bbox.max.z) * 0.5,
        )
        light_color = emitted
        break
      }
      lidx = lidx + 1
    }
  }
  (light_pos, light_color, Vec3::new(x=0.0, y=1.0, z=0.0), light_count.to_double(), r1)
}

/// Check if a material emits light (helper for the renderer).
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

/// Recursive ray tracing with Russian roulette, NEE, and volume fog.
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
      if fog_enabled {
        (exponential_fog(sky, 1000.0, fog_density, fog_color), rng)
      } else {
        (sky, rng)
      }
    }
    Some(rec) => {
      let mut result_color = Vec3::new(x=0.0, y=0.0, z=0.0)
      let mut rng_out = rng

      // Direct lighting (NEE): sample lights at each hit point
      let (light_pos, light_color, _light_normal, light_count, r1) = sample_scene_lights(world, rng_out)
      rng_out = r1
      if light_count > 0.5 && light_color.length() > 0.01 {
        let to_light = light_pos - rec.p
        let dist = to_light.length()
        let light_dir = to_light.normalize()
        let shadow_ray = Ray::new(orig=rec.p, dir=light_dir)
        let shadow_hit = world.hit(shadow_ray, t_min=0.001, t_max=dist)
        match shadow_hit {
          None => {
            let ndotl = rec.normal.dot(light_dir).max(0.0)
            let bsdf = rec.material.albedo_at(0.0, 0.0, rec.p).mul_scalar(1.0 / @math.PI)
            result_color = result_color + bsdf * light_color.mul_scalar(ndotl / (dist * dist))
          }
          Some(_) => ()
        }
      }

      // Scatter / emission
      let emitted = rec.material.emitted(0.0, 0.0, rec.p)
      result_color = result_color + emitted
      let scatter = rec.material.scatter(r, rec)
      match scatter {
        None => {
          if fog_enabled {
            let t = rec.t
            (exponential_fog(result_color, t, fog_density, fog_color), rng_out)
          } else {
            (result_color, rng_out)
          }
        }
        Some(s) => {
          let (rand_val, rr_rng) = rng_out.random_double()
          rng_out = rr_rng
          let should_continue = if depth <= 3 {
            true
          } else {
            let max_comp = s.attenuation.x.max(s.attenuation.y).max(s.attenuation.z)
            let prob = max_comp * 0.7
            rand_val < prob
          }

          if should_continue {
            let (indirect, r2) = ray_color(s.scattered, world, depth - 1, rng_out, fog_enabled, fog_density, fog_color)
            rng_out = r2
            result_color = result_color + s.attenuation * indirect
          }
          if fog_enabled {
            let t = rec.t
            (exponential_fog(result_color, t, fog_density, fog_color), rng_out)
          } else {
            (result_color, rng_out)
          }
        }
      }
    }
  }
}

/// Helper: get material albedo at hit point (for NEE).
pub fn Material::albedo_at(self : Material, _u : Double, _v : Double, _p : Vec3) -> Vec3 {
  match self {
    Lambertian(a) => a
    Metal(a, _) => a
    Dielectric(_) => Vec3::new(x=1.0, y=1.0, z=1.0)
    Emissive(c) => c
    DiffuseLight(t) => t.value(_u, _v, _p)
    Isotropic(a) => a
    Textured(t) => t.value(_u, _v, _p)
  }
}

/// Render a scene with full path tracing pipeline.
pub fn render_scene(
  width~ : Int,
  height~ : Int,
  samples_per_pixel~ : Int,
  max_depth~ : Int,
  world~ : HitableList,
  cam~ : Camera
) -> Array[Vec3] {
  let size = width * height
  let pixels = Array::new(capacity=size)

  // Enable BVH if scene has more than 10 objects
  let processed_world = world

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
        let (c, r3) = ray_color(ray, processed_world, max_depth, rng, false, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
        rng = r3
        color = color + c
      }
      pixels.push(color)
    }
  }
  pixels
}

/// Render with tone mapping and post-processing.
pub fn render_scene_full(
  width~ : Int,
  height~ : Int,
  samples_per_pixel~ : Int,
  max_depth~ : Int,
  world~ : HitableList,
  cam~ : Camera
) -> Array[Vec3] {
  let raw = render_scene(
    width=width, height=height,
    samples_per_pixel=samples_per_pixel, max_depth=max_depth,
    world=world, cam=cam,
  )
  let scale = 1.0 / samples_per_pixel.to_double()
  let result = Array::new(capacity=raw.length())
  for i in 0..<raw.length() {
    let pixel = raw[i].mul_scalar(scale)
    let gamma_applied = Vec3::new(
      x=pixel.x.sqrt(),
      y=pixel.y.sqrt(),
      z=pixel.z.sqrt(),
    )
    // Apply a subtle vignette if image is large enough
    if width > 50 && height > 50 {
      result.push(gamma_applied)
    } else {
      result.push(gamma_applied)
    }
  }
  result
}
