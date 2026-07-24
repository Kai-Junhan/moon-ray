///|
/// Demo scenes for moon-ray.

/// Simple scene with three spheres on a ground plane.
pub fn three_spheres_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  // Ground plane
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -100.5, z: -1.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.8, z: 0.0 }),
  )))

  // Center - matte sphere (reddish)
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.7, y: 0.3, z: 0.3 }),
  )))

  // Left - metal sphere (silver with some fuzz)
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -1.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Metal({ x: 0.8, y: 0.8, z: 0.8 }, 0.1),
  )))

  // Right - glass sphere
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 1.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Dielectric(1.5),
  )))

  let cam = Camera::default(aspect_ratio=16.0 / 9.0)
  (world, cam)
}

/// Cornell Box scene - classic test scene for global illumination
pub fn cornell_box_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  // Light source (ceiling) — positioned below ceiling inner surface (y=0.5)
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.4, z: 0.0 },
    radius=0.1,
    material=Material::Emissive({ x: 8.0, y: 8.0, z: 8.0 }),
  )))

  // Floor - white diffuse
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -100.5, z: 0.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.8, z: 0.8 }),
  )))

  // Left wall - red
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -100.5, y: 0.0, z: 0.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.1, z: 0.1 }),
  )))

  // Right wall - green
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 100.5, y: 0.0, z: 0.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.1, y: 0.8, z: 0.1 }),
  )))

  // Back wall - white
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.0, z: -100.5 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.8, z: 0.8 }),
  )))

  // Ceiling - white
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 100.5, z: 0.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.8, z: 0.8 }),
  )))

  // Center sphere - white diffuse
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -0.3, y: -0.25, z: -0.3 },
    radius=0.25,
    material=Material::Lambertian({ x: 0.9, y: 0.9, z: 0.9 }),
  )))

  // Right sphere - metal
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.4, y: -0.35, z: 0.2 },
    radius=0.15,
    material=Material::Metal({ x: 0.9, y: 0.9, z: 0.9 }, 0.05),
  )))

  // Glass sphere
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -0.35, z: 0.5 },
    radius=0.15,
    material=Material::Dielectric(1.5),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 0.0, z: 2.0 },
    lookat={ x: 0.0, y: 0.0, z: 0.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=60.0,
    aspect_ratio=1.0,
    aperture=0.0,
    focus_dist=2.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

/// Random spheres scene - similar to "Ray Tracing in One Weekend"
pub fn random_spheres_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()
  let mut rng = new_rng(123456789UL)

  // Ground
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -1000.0, z: 0.0 },
    radius=1000.0,
    material=Material::Lambertian({ x: 0.5, y: 0.5, z: 0.5 }),
  )))

  // Random small spheres
  for a in -5..=5 {
    for b in -5..=5 {
      let (rand_mat, rng1) = rng.random_double()
      rng = rng1
      let center = {
        x: a.to_double() + 0.9 * rng.random_double().0,
        y: 0.2,
        z: b.to_double() + 0.9 * rng.random_double().0,
      }

      if (center - { x: 4.0, y: 0.2, z: 0.0 }).length() > 0.9 {
        if rand_mat < 0.6 {
          // Diffuse
          let (r1, rng2) = rng.random_double()
          let (r2, rng3) = rng2.random_double()
          let (r3, rng4) = rng3.random_double()
          rng = rng4
          let albedo = { x: r1 * r2, y: r2 * r3, z: r3 * r1 }
          world = world.add(Hitable::Sphere(Sphere::new(
            center=center,
            radius=0.2,
            material=Material::Lambertian(albedo),
          )))
        } else if rand_mat < 0.85 {
          // Metal
          let (r1, rng2) = rng.random_double_range(min=0.5, max=1.0)
          let (r2, rng3) = rng2.random_double_range(min=0.5, max=1.0)
          let (r3, rng4) = rng3.random_double_range(min=0.5, max=1.0)
          let (fuzz, rng5) = rng4.random_double_range(min=0.0, max=0.5)
          rng = rng5
          let albedo = { x: r1, y: r2, z: r3 }
          world = world.add(Hitable::Sphere(Sphere::new(
            center=center,
            radius=0.2,
            material=Material::Metal(albedo, fuzz),
          )))
        } else {
          // Glass
          world = world.add(Hitable::Sphere(Sphere::new(
            center=center,
            radius=0.2,
            material=Material::Dielectric(1.5),
          )))
        }
      }
    }
  }

  // Three large spheres
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 1.0, z: 0.0 },
    radius=1.0,
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -4.0, y: 1.0, z: 0.0 },
    radius=1.0,
    material=Material::Lambertian({ x: 0.4, y: 0.2, z: 0.1 }),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 4.0, y: 1.0, z: 0.0 },
    radius=1.0,
    material=Material::Metal({ x: 0.7, y: 0.6, z: 0.5 }, 0.0),
  )))

  let cam = Camera::new(
    lookfrom={ x: 13.0, y: 2.0, z: 3.0 },
    lookat={ x: 0.0, y: 0.0, z: 0.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=20.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.1,
    focus_dist=10.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

/// Material showcase scene - demonstrates all material types
pub fn material_showcase_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  // Ground
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -100.5, z: -1.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.5, y: 0.5, z: 0.5 }),
  )))

  // Row 1: Lambertian materials (different colors)
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -2.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.9, y: 0.1, z: 0.1 }), // Red
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -0.7, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.1, y: 0.9, z: 0.1 }), // Green
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.7, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.1, y: 0.1, z: 0.9 }), // Blue
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 2.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.9, y: 0.9, z: 0.1 }), // Yellow
  )))

  // Row 2: Metal materials (different fuzz values)
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -2.0, y: 0.0, z: -2.5 },
    radius=0.5,
    material=Material::Metal({ x: 0.9, y: 0.1, z: 0.1 }, 0.0), // Perfect mirror
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -0.7, y: 0.0, z: -2.5 },
    radius=0.5,
    material=Material::Metal({ x: 0.9, y: 0.9, z: 0.9 }, 0.1), // Slight fuzz
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.7, y: 0.0, z: -2.5 },
    radius=0.5,
    material=Material::Metal({ x: 0.9, y: 0.9, z: 0.9 }, 0.3), // Medium fuzz
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 2.0, y: 0.0, z: -2.5 },
    radius=0.5,
    material=Material::Metal({ x: 0.9, y: 0.9, z: 0.9 }, 0.5), // High fuzz
  )))

  // Row 3: Dielectric (glass) with different IOR
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -1.5, y: 0.0, z: -4.0 },
    radius=0.5,
    material=Material::Dielectric(1.33), // Water-like
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.0, z: -4.0 },
    radius=0.5,
    material=Material::Dielectric(1.5), // Glass
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 1.5, y: 0.0, z: -4.0 },
    radius=0.5,
    material=Material::Dielectric(2.42), // Diamond-like
  )))

  // Light source
  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 3.0, z: -2.0 },
    radius=0.5,
    material=Material::Emissive({ x: 5.0, y: 5.0, z: 5.0 }),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.0, z: 4.0 },
    lookat={ x: 0.0, y: 0.0, z: -2.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=45.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.0,
    focus_dist=4.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}
