///|
/// Advanced demo scenes for moon-ray.
/// Visually impressive scenes demonstrating the renderer's capabilities.

pub fn mirror_corridor_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let silver = Material::Metal(Vec3::new(x=0.95, y=0.95, z=0.95), 0.0)
  let gold = Material::Metal(Vec3::new(x=0.95, y=0.65, z=0.15), 0.02)

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=-0.5, z=0.0),
    normal=Vec3::new(x=0.0, y=1.0, z=0.0),
    material=Material::Textured(Texture::Checker(
      Texture::Solid(Vec3::new(x=0.05, y=0.05, z=0.1)),
      Texture::Solid(Vec3::new(x=0.02, y=0.02, z=0.05)),
      8.0,
    )),
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=3.0, z=0.0),
    normal=Vec3::new(x=0.0, y=-1.0, z=0.0),
    material=silver,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=-3.0, y=1.0, z=0.0),
    normal=Vec3::new(x=1.0, y=0.0, z=0.0),
    material=silver,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=3.0, y=1.0, z=0.0),
    normal=Vec3::new(x=-1.0, y=0.0, z=0.0),
    material=silver,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=1.0, z=-5.0),
    normal=Vec3::new(x=0.0, y=0.0, z=1.0),
    material=silver,
  )))

  for row in 0..<5 {
    for col in 0..<3 {
      let x = (-2.0) + col.to_double() * 2.0
      let z = (-2.0) - row.to_double() * 0.8
      let y = 0.0 + (row.to_double() * 0.2)
      world = world.add(Hitable::Sphere(Sphere::new(
        center=Vec3::new(x=x, y=y, z=z),
        radius=0.18 + row.to_double() * 0.02,
        material=if (row + col) % 2 == 0 { gold } else { silver },
      )))
    }
  }

  world = world.add(Hitable::Disk(Disk::new(
    center=Vec3::new(x=0.0, y=2.8, z=-1.5),
    normal=Vec3::new(x=0.0, y=-1.0, z=0.0),
    radius=1.2,
    material=Material::DiffuseLight(Texture::Solid(Vec3::new(x=15.0, y=13.0, z=10.0))),
  )))

  let cam = Camera::new(
    lookfrom=Vec3::new(x=0.0, y=1.2, z=2.5),
    lookat=Vec3::new(x=0.0, y=0.5, z=-1.5),
    vup=Vec3::new(x=0.0, y=1.0, z=0.0),
    vfov=55.0, aspect_ratio=16.0 / 9.0,
    aperture=0.02, focus_dist=3.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn crystal_garden_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let dark = Material::Lambertian(Vec3::new(x=0.02, y=0.02, z=0.03))
  let warm_light = Material::DiffuseLight(Texture::Solid(Vec3::new(x=20.0, y=16.0, z=10.0)))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=-1.5, z=0.0),
    normal=Vec3::new(x=0.0, y=1.0, z=0.0),
    material=dark,
  )))

  let glass = Material::Dielectric(1.52)
  let blue_glass = Material::Dielectric(1.45)
  let water = Material::Dielectric(1.33)
  let diamond = Material::Dielectric(2.42)

  world = world.add(Hitable::Sphere(Sphere::new(
    center=Vec3::new(x=-2.5, y=0.4, z=-2.0),
    radius=0.5, material=diamond,
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center=Vec3::new(x=-1.2, y=0.25, z=-1.5),
    size=Vec3::new(x=0.5, y=0.5, z=0.5),
    material=glass,
  )))

  world = world.add(Hitable::Cylinder(Cylinder::new(
    center=Vec3::new(x=0.0, y=0.0, z=-2.5),
    radius=0.25, height=1.8,
    material=blue_glass,
  )))

  world = world.add(Hitable::Cone(Cone::new(
    base_center=Vec3::new(x=1.5, y=-0.3, z=-1.8),
    base_radius=0.4, height=1.5,
    material=water,
  )))

  world = world.add(Hitable::Torus(Torus::new(
    center=Vec3::new(x=2.8, y=0.3, z=-2.2),
    major_radius=0.35, minor_radius=0.12,
    material=glass,
  )))

  for i in 0..<8 {
    let angle = i.to_double() / 8.0 * 2.0 * @math.PI
    let r = 3.5
    let x = r * @math.cos(angle)
    let z = r * @math.sin(angle) - 1.0
    world = world.add(Hitable::Disk(Disk::new(
      center=Vec3::new(x=x, y=3.5, z=z),
      normal=Vec3::new(x=-x/r, y=-0.3, z=-z/r),
      radius=0.25,
      material=if i % 2 == 0 {
        warm_light
      } else {
        Material::DiffuseLight(Texture::Solid(Vec3::new(x=10.0, y=20.0, z=25.0)))
      },
    )))
  }

  world = world.add(Hitable::Disk(Disk::new(
    center=Vec3::new(x=0.0, y=4.0, z=-1.0),
    normal=Vec3::new(x=0.0, y=-1.0, z=0.0),
    radius=1.0,
    material=warm_light,
  )))

  let cam = Camera::new(
    lookfrom=Vec3::new(x=0.0, y=2.0, z=5.0),
    lookat=Vec3::new(x=0.0, y=0.3, z=-2.0),
    vup=Vec3::new(x=0.0, y=1.0, z=0.0),
    vfov=45.0, aspect_ratio=16.0 / 9.0,
    aperture=0.03, focus_dist=6.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn sunrise_valley_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let grass = Material::Lambertian(Vec3::new(x=0.15, y=0.45, z=0.1))
  let stone = Material::Lambertian(Vec3::new(x=0.45, y=0.4, z=0.35))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=-5.0, z=0.0),
    normal=Vec3::new(x=0.0, y=1.0, z=0.0),
    material=Material::Textured(Texture::Checker(
      Texture::Solid(Vec3::new(x=0.12, y=0.4, z=0.08)),
      Texture::Solid(Vec3::new(x=0.18, y=0.5, z=0.12)),
      0.5,
    )),
  )))

  let rng1 = new_rng(123UL)
  for _i in 0..<40 {
    let (ang, r1) = rng1.random_double_range(min=0.0, max=2.0 * @math.PI)
    let (rad, r2) = r1.random_double_range(min=5.0, max=20.0)
    let (sx, r3) = r2.random_double_range(min=0.3, max=1.5)
    let (sz, _) = r3.random_double_range(min=0.3, max=1.5)
    let x = rad * @math.cos(ang)
    let z = rad * @math.sin(ang)
    let h = 0.5 + (rad / 20.0) * 3.0
    world = world.add(Hitable::BoxShape(BoxShape::new(
      center=Vec3::new(x=x, y=-5.0 + h/2.0, z=z),
      size=Vec3::new(x=sx, y=h, z=sz),
      material=stone,
    )))
  }

  for _j in 0..<15 {
    let (ang2, r4) = rng1.random_double_range(min=0.0, max=2.0 * @math.PI)
    let (rad2, r5) = r4.random_double_range(min=4.0, max=12.0)
    let (size2, _) = r5.random_double_range(min=0.2, max=0.5)
    let x = rad2 * @math.cos(ang2)
    let z = rad2 * @math.sin(ang2)
    world = world.add(Hitable::Sphere(Sphere::new(
      center=Vec3::new(x=x, y=-4.5, z=z),
      radius=size2,
      material=grass,
    )))
  }

  world = world.add(Hitable::Sphere(Sphere::new(
    center=Vec3::new(x=2.0, y=0.3, z=-3.0),
    radius=1.0,
    material=Material::Metal(Vec3::new(x=0.95, y=0.85, z=0.7), 0.02),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center=Vec3::new(x=-3.0, y=0.6, z=-5.0),
    radius=1.5,
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center=Vec3::new(x=10.0, y=8.0, z=-12.0),
    normal=Vec3::new(x=-0.5, y=-0.6, z=0.6),
    radius=5.0,
    material=Material::DiffuseLight(Texture::Solid(Vec3::new(x=30.0, y=20.0, z=8.0))),
  )))

  let cam = Camera::new(
    lookfrom=Vec3::new(x=0.0, y=1.5, z=4.0),
    lookat=Vec3::new(x=0.0, y=0.0, z=-4.0),
    vup=Vec3::new(x=0.0, y=1.0, z=0.0),
    vfov=60.0, aspect_ratio=16.0 / 9.0,
    aperture=0.05, focus_dist=6.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn prism_lab_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let white = Material::Lambertian(Vec3::new(x=0.85, y=0.85, z=0.85))
  let black = Material::Lambertian(Vec3::new(x=0.03, y=0.03, z=0.03))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=-1.0, z=0.0),
    normal=Vec3::new(x=0.0, y=1.0, z=0.0),
    material=black,
  )))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=0.0, z=-6.0),
    normal=Vec3::new(x=0.0, y=0.0, z=1.0),
    material=white,
  )))

  for i in 0..<6 {
    let x = (-2.5) + i.to_double() * 1.0
    let ior_list = [1.33, 1.45, 1.52, 1.62, 1.77, 2.42]
    let ior = ior_list[i]
    let mat = Material::Dielectric(ior)
    let h = 0.5 + i.to_double() * 0.2

    world = world.add(Hitable::Cone(Cone::new(
      base_center=Vec3::new(x=x, y=-1.0, z=-3.5),
      base_radius=0.25 + i.to_double() * 0.03,
      height=h,
      material=mat,
    )))

    world = world.add(Hitable::BoxShape(BoxShape::new(
      center=Vec3::new(x=x, y=-0.7 + h/4.0, z=-2.0),
      size=Vec3::new(x=0.2, y=0.3, z=0.2),
      material=mat,
    )))
  }

  let colors = [
    Vec3::new(x=1.0, y=0.2, z=0.2),
    Vec3::new(x=0.2, y=1.0, z=0.2),
    Vec3::new(x=0.2, y=0.2, z=1.0),
    Vec3::new(x=1.0, y=1.0, z=0.2),
    Vec3::new(x=1.0, y=0.2, z=1.0),
    Vec3::new(x=0.2, y=1.0, z=1.0),
  ]
  for i in 0..<6 {
    let x = (-2.5) + i.to_double() * 1.0
    world = world.add(Hitable::Disk(Disk::new(
      center=Vec3::new(x=x, y=3.0, z=-3.0),
      normal=Vec3::new(x=0.0, y=-1.0, z=0.1),
      radius=0.2,
      material=Material::DiffuseLight(Texture::Solid(colors[i].mul_scalar(12.0))),
    )))
  }

  let cam = Camera::new(
    lookfrom=Vec3::new(x=0.0, y=1.2, z=2.5),
    lookat=Vec3::new(x=0.0, y=0.0, z=-3.0),
    vup=Vec3::new(x=0.0, y=1.0, z=0.0),
    vfov=50.0, aspect_ratio=16.0 / 9.0,
    aperture=0.02, focus_dist=4.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn city_at_night_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  let concrete = Material::Lambertian(Vec3::new(x=0.35, y=0.35, z=0.38))
  let glass_blue = Material::Metal(Vec3::new(x=0.3, y=0.4, z=0.7), 0.05)
  let glass_gold = Material::Metal(Vec3::new(x=0.8, y=0.6, z=0.3), 0.03)
  let dark_ground = Material::Lambertian(Vec3::new(x=0.05, y=0.05, z=0.08))

  world = world.add(Hitable::Plane(Plane::new(
    center=Vec3::new(x=0.0, y=-1.0, z=0.0),
    normal=Vec3::new(x=0.0, y=1.0, z=0.0),
    material=dark_ground,
  )))

  let w_rng = new_rng(456UL)
  for i in 0..<30 {
    let (xoff, r1) = w_rng.random_double_range(min=-0.3, max=0.3)
    let (zoff, r2) = r1.random_double_range(min=-0.3, max=0.3)
    let (h, r3) = r2.random_double_range(min=0.5, max=2.5)
    let (w, _) = r3.random_double_range(min=0.3, max=0.8)
    let grid_x = (i % 6).to_double() - 2.5
    let grid_z = (i / 6).to_double() - 2.5
    let x = grid_x * 1.5 + xoff
    let z = grid_z * 1.8 + zoff

    let mat = if i % 3 == 0 { glass_blue }
              else if i % 3 == 1 { glass_gold }
              else { concrete }

    world = world.add(Hitable::BoxShape(BoxShape::new(
      center=Vec3::new(x=x, y=-1.0 + h/2.0, z=z-3.0),
      size=Vec3::new(x=w, y=h, z=w),
      material=mat,
    )))

    if i % 4 == 0 {
      world = world.add(Hitable::Disk(Disk::new(
        center=Vec3::new(x=x, y=-0.3 + h/2.0, z=z-3.0 + w/2.0 + 0.01),
        normal=Vec3::new(x=0.0, y=0.0, z=-1.0),
        radius=w * 0.15,
        material=Material::Emissive(Vec3::new(x=5.0, y=3.0, z=1.5)),
      )))
    }
    if i % 7 == 0 {
      world = world.add(Hitable::Disk(Disk::new(
        center=Vec3::new(x=x, y=-0.8 + h/2.0, z=z-3.0 + w/2.0 + 0.01),
        normal=Vec3::new(x=0.0, y=0.0, z=-1.0),
        radius=w * 0.12,
        material=Material::Emissive(Vec3::new(x=2.0, y=4.0, z=8.0)),
      )))
    }
  }

  let cam = Camera::new(
    lookfrom=Vec3::new(x=0.0, y=1.5, z=2.0),
    lookat=Vec3::new(x=0.0, y=-0.2, z=-4.0),
    vup=Vec3::new(x=0.0, y=1.0, z=0.0),
    vfov=65.0, aspect_ratio=16.0 / 9.0,
    aperture=0.05, focus_dist=5.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}
