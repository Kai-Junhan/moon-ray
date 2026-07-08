///|
/// Extended demo scenes using new geometry types and materials.

pub fn geometric_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -1000.0, z: 0.0 },
    radius=1000.0,
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.2, y: 0.3, z: 0.1 }),
      odd=Texture::Solid({ x: 0.9, y: 0.9, z: 0.9 }),
      scale=5.0,
    )),
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: -1.5, y: 0.25, z: -1.0 },
    size={ x: 0.5, y: 0.5, z: 0.5 },
    material=Material::Metal({ x: 0.9, y: 0.1, z: 0.1 }, 0.0),
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: 0.0, y: 0.25, z: -1.0 },
    size={ x: 0.5, y: 0.5, z: 0.5 },
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: 1.5, y: 0.25, z: -1.0 },
    size={ x: 0.5, y: 0.5, z: 0.5 },
    material=Material::Lambertian({ x: 0.1, y: 0.4, z: 0.9 }),
  )))

  world = world.add(Hitable::Cylinder(Cylinder::new(
    center={ x: -0.75, y: -0.15, z: -0.5 },
    radius=0.25,
    height=1.2,
    material=Material::Metal({ x: 0.8, y: 0.8, z: 0.8 }, 0.1),
  )))

  world = world.add(Hitable::Cylinder(Cylinder::new(
    center={ x: 0.75, y: -0.15, z: -0.5 },
    radius=0.25,
    height=1.2,
    material=Material::Lambertian({ x: 0.9, y: 0.6, z: 0.1 }),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 1.5, z: -1.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=0.5,
    material=Material::DiffuseLight(Texture::Solid({ x: 4.0, y: 4.0, z: 4.0 })),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.5, z: 4.0 },
    lookat={ x: 0.0, y: 0.0, z: -1.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=40.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.0,
    focus_dist=4.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

pub fn cornel_box_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let red = Material::Lambertian({ x: 0.65, y: 0.05, z: 0.05 })
  let white = Material::Lambertian({ x: 0.73, y: 0.73, z: 0.73 })
  let green = Material::Lambertian({ x: 0.12, y: 0.45, z: 0.15 })
  let light = Material::DiffuseLight(Texture::Solid({ x: 15.0, y: 15.0, z: 15.0 }))

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: 0.0, z: 0.0 },
    normal={ x: 0.0, y: 1.0, z: 0.0 },
    material=white,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: 2.0, z: 0.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    material=white,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: -2.0, y: 1.0, z: 0.0 },
    normal={ x: 1.0, y: 0.0, z: 0.0 },
    material=red,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 2.0, y: 1.0, z: 0.0 },
    normal={ x: -1.0, y: 0.0, z: 0.0 },
    material=green,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: 1.0, z: -2.0 },
    normal={ x: 0.0, y: 0.0, z: 1.0 },
    material=white,
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 1.99, z: 0.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=0.5,
    material=light,
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: -0.5, y: 0.25, z: -0.8 },
    size={ x: 0.5, y: 0.5, z: 0.5 },
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: 0.5, y: 0.3, z: -0.6 },
    size={ x: 0.4, y: 0.6, z: 0.4 },
    material=Material::Metal({ x: 0.8, y: 0.8, z: 0.9 }, 0.05),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.0, z: 3.0 },
    lookat={ x: 0.0, y: 1.0, z: 0.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=40.0,
    aspect_ratio=1.0,
    aperture=0.0,
    focus_dist=3.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

pub fn texture_demo_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -1000.0, z: 0.0 },
    radius=1000.0,
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.0, y: 0.0, z: 0.0 }),
      odd=Texture::Solid({ x: 1.0, y: 1.0, z: 1.0 }),
      scale=10.0,
    )),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -2.0, y: 1.0, z: -1.0 },
    radius=1.0,
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.9, y: 0.1, z: 0.1 }),
      odd=Texture::Solid({ x: 0.1, y: 0.1, z: 0.9 }),
      scale=8.0,
    )),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 1.0, z: -1.0 },
    radius=1.0,
    material=Material::Textured(Texture::Noise(4.0)),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 2.0, y: 1.0, z: -1.0 },
    radius=1.0,
    material=Material::Metal({ x: 0.9, y: 0.6, z: 0.1 }, 0.0),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 3.5, z: -1.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=2.0,
    material=Material::DiffuseLight(Texture::Solid({ x: 8.0, y: 7.0, z: 5.0 })),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 2.0, z: 6.0 },
    lookat={ x: 0.0, y: 1.0, z: -1.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=35.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.0,
    focus_dist=6.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

pub fn triangle_demo_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Triangle(Triangle::new(
    v0={ x: -1.5, y: 0.0, z: -1.5 },
    v1={ x: 0.0, y: 1.5, z: -1.5 },
    v2={ x: 1.5, y: 0.0, z: -1.5 },
    material=Material::Lambertian({ x: 0.9, y: 0.1, z: 0.1 }),
  )))

  world = world.add(Hitable::Triangle(Triangle::new(
    v0={ x: -1.5, y: 0.1, z: -2.0 },
    v1={ x: 0.0, y: 1.6, z: -2.0 },
    v2={ x: 1.5, y: 0.1, z: -2.0 },
    material=Material::Lambertian({ x: 0.1, y: 0.9, z: 0.1 }),
  )))

  world = world.add(Hitable::Triangle(Triangle::new(
    v0={ x: -1.5, y: 0.2, z: -2.5 },
    v1={ x: 0.0, y: 1.7, z: -2.5 },
    v2={ x: 1.5, y: 0.2, z: -2.5 },
    material=Material::Lambertian({ x: 0.1, y: 0.1, z: 0.9 }),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -100.5, z: 0.0 },
    radius=100.0,
    material=Material::Lambertian({ x: 0.8, y: 0.8, z: 0.8 }),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.0, z: 2.0 },
    lookat={ x: 0.0, y: 0.5, z: -2.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=60.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.0,
    focus_dist=3.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}

pub fn final_demo_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()
  let mut rng = new_rng(42UL)

  for a in -5..=5 {
    for b in -5..=5 {
      let (rand_mat, r1) = rng.random_double()
      rng = r1
      let (dx, r2) = rng.random_double_range(min=-0.3, max=0.3)
      let (dz, r3) = r2.random_double_range(min=-0.3, max=0.3)
      rng = r3

      let cx = a.to_double() + dx
      let cz = b.to_double() + dz
      let center = { x: cx, y: 0.15, z: cz }

      if rand_mat < 0.4 {
        let (r1, r4) = rng.random_double()
        let (r2, r5) = r4.random_double()
        let (r3, r6) = r5.random_double()
        rng = r6
        world = world.add(Hitable::Sphere(Sphere::new(
          center=center, radius=0.15,
          material=Material::Lambertian({ x: r1 * r2, y: r2 * r3, z: r3 * r1 }),
        )))
      } else if rand_mat < 0.65 {
        let (r1, r4) = rng.random_double_range(min=0.5, max=1.0)
        let (r2, r5) = r4.random_double_range(min=0.5, max=1.0)
        let (r3, r6) = r5.random_double_range(min=0.5, max=1.0)
        let (fuzz, r7) = r6.random_double_range(min=0.0, max=0.3)
        rng = r7
        world = world.add(Hitable::BoxShape(BoxShape::new(
          center=center, size={ x: 0.3, y: 0.3, z: 0.3 },
          material=Material::Metal({ x: r1, y: r2, z: r3 }, fuzz),
        )))
      } else if rand_mat < 0.85 {
        world = world.add(Hitable::Cylinder(Cylinder::new(
          center=center, radius=0.1, height=0.3,
          material=Material::Dielectric(1.5),
        )))
      } else {
        world = world.add(Hitable::Sphere(Sphere::new(
          center=center, radius=0.15,
          material=Material::Dielectric(1.5),
        )))
      }
    }
  }

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: -0.15, z: 0.0 },
    normal={ x: 0.0, y: 1.0, z: 0.0 },
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.05, y: 0.05, z: 0.05 }),
      odd=Texture::Solid({ x: 0.95, y: 0.95, z: 0.95 }),
      scale=3.0,
    )),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 4.0, z: 0.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=3.0,
    material=Material::DiffuseLight(Texture::Solid({ x: 12.0, y: 11.0, z: 9.0 })),
  )))

  let cam = Camera::new(
    lookfrom={ x: 8.0, y: 3.5, z: 8.0 },
    lookat={ x: 0.0, y: 0.0, z: 0.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=35.0,
    aspect_ratio=16.0 / 9.0,
    aperture=0.05,
    focus_dist=10.0,
    time0=0.0,
    time1=0.0,
  )
  (world, cam)
}
