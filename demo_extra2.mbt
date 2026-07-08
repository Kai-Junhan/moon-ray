///|
/// Extended demo scenes with all geometry types and advanced effects.

pub fn full_geometry_demo() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: -2.0, z: 0.0 },
    normal={ x: 0.0, y: 1.0, z: 0.0 },
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.1, y: 0.1, z: 0.1 }),
      odd=Texture::Solid({ x: 0.8, y: 0.8, z: 0.8 }),
      scale=3.0,
    )),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -3.0, y: 0.0, z: 0.0 },
    radius=1.0,
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::BoxShape(BoxShape::new(
    center={ x: -1.0, y: 0.0, z: 0.0 },
    size={ x: 1.0, y: 1.0, z: 1.0 },
    material=Material::Metal({ x: 0.9, y: 0.1, z: 0.1 }, 0.05),
  )))

  world = world.add(Hitable::Cylinder(Cylinder::new(
    center={ x: 1.0, y: 0.0, z: 0.0 },
    radius=0.5,
    height=1.5,
    material=Material::Metal({ x: 0.1, y: 0.1, z: 0.9 }, 0.1),
  )))

  world = world.add(Hitable::Cone(Cone::new(
    base_center={ x: 3.0, y: -0.5, z: 0.0 },
    base_radius=0.6,
    height=1.5,
    material=Material::Lambertian({ x: 0.9, y: 0.6, z: 0.1 }),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 3.0, z: 0.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=2.0,
    material=Material::DiffuseLight(Texture::Solid({ x: 8.0, y: 7.0, z: 5.0 })),
  )))

  let mesh_cube = Mesh::build_cube(center={ x: -3.0, y: 1.5, z: -2.0 }, size=0.6, material=Material::Dielectric(1.5))
  let cube_hitables = mesh_to_hitable_list(mesh_cube)
  for i in 0..<cube_hitables.objects.length() {
    world = world.add(cube_hitables.objects[i])
  }

  let mesh_sphere = Mesh::build_uv_sphere(center={ x: 3.0, y: 1.5, z: -2.0 }, radius=0.5, segments=16, rings=8, material=Material::Metal({ x: 0.8, y: 0.6, z: 0.2 }, 0.0))
  let sphere_hitables = mesh_to_hitable_list(mesh_sphere)
  for i in 0..<sphere_hitables.objects.length() {
    world = world.add(sphere_hitables.objects[i])
  }

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 2.0, z: 8.0 },
    lookat={ x: 0.0, y: 0.0, z: 0.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=40.0, aspect_ratio=16.0 / 9.0, aperture=0.0, focus_dist=8.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn studio_lighting_demo() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: -1.0, z: 0.0 },
    normal={ x: 0.0, y: 1.0, z: 0.0 },
    material=Material::Lambertian({ x: 0.2, y: 0.2, z: 0.2 }),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 5.0, z: 0.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=1.5,
    material=Material::DiffuseLight(Texture::Solid({ x: 20.0, y: 20.0, z: 20.0 })),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: -4.0, y: 2.0, z: 2.0 },
    normal={ x: 1.0, y: -0.5, z: -0.5 },
    radius=0.5,
    material=Material::DiffuseLight(Texture::Solid({ x: 15.0, y: 5.0, z: 5.0 })),
  )))

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 4.0, y: 2.0, z: 2.0 },
    normal={ x: -1.0, y: -0.5, z: -0.5 },
    radius=0.5,
    material=Material::DiffuseLight(Texture::Solid({ x: 5.0, y: 5.0, z: 15.0 })),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -1.5, y: 0.3, z: -1.0 },
    radius=0.5,
    material=Material::Metal({ x: 0.9, y: 0.9, z: 0.9 }, 0.0),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.3, z: -0.5 },
    radius=0.5,
    material=Material::Dielectric(1.5),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 1.5, y: 0.3, z: -1.0 },
    radius=0.5,
    material=Material::Lambertian({ x: 0.9, y: 0.3, z: 0.1 }),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.5, z: 4.0 },
    lookat={ x: 0.0, y: 0.3, z: -0.5 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=45.0, aspect_ratio=16.0 / 9.0, aperture=0.0, focus_dist=4.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn depth_of_field_demo() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Plane(Plane::new(
    center={ x: 0.0, y: -1.0, z: 0.0 },
    normal={ x: 0.0, y: 1.0, z: 0.0 },
    material=Material::Lambertian({ x: 0.3, y: 0.7, z: 0.3 }),
  )))

  for z in 0..<5 {
    let z_pos = (-z).to_double() * 1.5 - 1.0
    let r = 0.2 + (4 - z).to_double() * 0.02
    world = world.add(Hitable::Sphere(Sphere::new(
      center={ x: 0.0, y: 0.0, z: z_pos },
      radius=r,
      material=Material::Metal({ x: 0.9, y: 0.1, z: 0.1 }, 0.0),
    )))
  }

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 0.5, z: 2.0 },
    lookat={ x: 0.0, y: 0.0, z: -3.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=60.0, aspect_ratio=16.0 / 9.0, aperture=0.3, focus_dist=3.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}

pub fn foggy_scene_demo() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -1000.0, z: 0.0 },
    radius=1000.0,
    material=Material::Textured(Texture::checker(
      even=Texture::Solid({ x: 0.9, y: 0.9, z: 0.9 }),
      odd=Texture::Solid({ x: 0.1, y: 0.2, z: 0.3 }),
      scale=2.0,
    )),
  )))

  let positions = Array::new(capacity=5)
  positions.push((-2.0, -1.0))
  positions.push((0.0, -1.5))
  positions.push((2.0, -2.0))
  positions.push((-1.0, -2.5))
  positions.push((1.0, -3.0))
  for i in 0..<5 {
    let (x, z) = positions[i]
    world = world.add(Hitable::Sphere(Sphere::new(
      center={ x, y: 0.3, z },
      radius=0.3,
      material=Material::Lambertian({ x: 0.8, y: 0.2, z: 0.1 }),
    )))
  }

  world = world.add(Hitable::Disk(Disk::new(
    center={ x: 0.0, y: 2.0, z: -1.0 },
    normal={ x: 0.0, y: -1.0, z: 0.0 },
    radius=1.0,
    material=Material::DiffuseLight(Texture::Solid({ x: 6.0, y: 5.0, z: 4.0 })),
  )))

  let cam = Camera::new(
    lookfrom={ x: 0.0, y: 1.0, z: 3.0 },
    lookat={ x: 0.0, y: 0.0, z: -2.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=50.0, aspect_ratio=16.0 / 9.0, aperture=0.0, focus_dist=4.0,
    time0=0.0, time1=0.0,
  )
  (world, cam)
}
