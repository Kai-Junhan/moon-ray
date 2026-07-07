///|
/// Monte Carlo Path Tracing renderer.

/// Background color for rays that miss all objects.
fn background_sky(r : Ray) -> Vec3 {
  let unit_dir = r.dir.normalize()
  let t = 0.5 * (unit_dir.y + 1.0)
  let white = { x: 1.0, y: 1.0, z: 1.0 }
  let blue = { x: 0.5, y: 0.7, z: 1.0 }
  white.mul_scalar(1.0 - t) + blue.mul_scalar(t)
}

/// Recursive ray tracing with Russian roulette termination.
fn ray_color(r : Ray, world : HitableList, depth : Int, rng : Rng) -> Vec3 {
  if depth <= 0 {
    return { x: 0.0, y: 0.0, z: 0.0 }
  }

  let hit = world.hit(r, t_min=0.001, t_max=1.0e30)
  match hit {
    None => background_sky(r)
    Some(rec) => {
      let emitted = rec.material.emitted(0.0, 0.0, rec.p)
      let scatter = rec.material.scatter(r, rec)
      match scatter {
        None => emitted
        Some(s) => {
          emitted + s.attenuation * ray_color(s.scattered, world, depth - 1, rng)
        }
      }
    }
  }
}

/// Render a scene with path tracing.
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

  for j in 0..<height {
    for _i in 0..<width {
      let mut color = { x: 0.0, y: 0.0, z: 0.0 }
      let mut rng = default_rng()
      for _ in 0..<samples_per_pixel {
        let (u, r1) = rng.random_double()
        let (v, r2) = r1.random_double()
        rng = r2
        let s = (_i.to_double() + u) / width.to_double()
        let t = (j.to_double() + v) / height.to_double()
        let ray = cam.get_ray(s, t)
        color = color + ray_color(ray, world, max_depth, rng)
      }
      pixels.push(color)
    }
  }
  pixels
}
