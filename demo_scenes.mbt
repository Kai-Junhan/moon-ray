///|
/// Demo scenes for moon-ray.

/// Simple scene with three spheres on a ground plane.
pub fn three_spheres_scene() -> (HitableList, Camera) {
  let mut world = HitableList::new()

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: -100.5, z: -1.0 },
    radius=100.0,
    material=Lambertian({ x: 0.8, y: 0.8, z: 0.0 }),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 0.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Lambertian({ x: 0.7, y: 0.3, z: 0.3 }),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: -1.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Metal({ x: 0.8, y: 0.8, z: 0.8 }, 0.3),
  )))

  world = world.add(Hitable::Sphere(Sphere::new(
    center={ x: 1.0, y: 0.0, z: -1.0 },
    radius=0.5,
    material=Dielectric(1.5),
  )))

  let cam = Camera::default(aspect_ratio=16.0 / 9.0)
  (world, cam)
}
