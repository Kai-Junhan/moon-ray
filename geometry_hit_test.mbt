test "sphere_hit" {
  let s = Sphere::new(center=Vec3::new(x=0.0, y=0.0, z=-1.0), radius=1.0, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::Sphere(s).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(rec) => assert_true(rec.t > -0.1) }
}
test "sphere_miss" {
  let s = Sphere::new(center=Vec3::new(x=0.0, y=0.0, z=-1.0), radius=0.5, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.6, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::Sphere(s).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => (); Some(_) => assert_true(false) }
}
test "plane_hit" {
  let p = Plane::new(center=Vec3::new(x=0.0, y=0.0, z=-2.0), normal=Vec3::new(x=0.0, y=0.0, z=1.0), material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::Plane(p).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(rec) => assert_true((rec.t - 2.0).abs() < 0.01) }
}
test "box_hit" {
  let bx = BoxShape::new(center=Vec3::new(x=0.0, y=0.0, z=-2.0), size=Vec3::new(x=1.0, y=1.0, z=1.0), material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::BoxShape(bx).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(_) => () }
}
test "cylinder_hit" {
  let cyl = Cylinder::new(center=Vec3::new(x=0.0, y=0.0, z=-2.0), radius=0.5, height=1.0, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.4, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::Cylinder(cyl).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(_) => () }
}
test "disk_hit" {
  let dk = Disk::new(center=Vec3::new(x=0.0, y=0.0, z=-2.0), normal=Vec3::new(x=0.0, y=0.0, z=1.0), radius=1.0, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = Hitable::Disk(dk).hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(rec) => assert_true((rec.t - 2.0).abs() < 0.01) }
}
test "list_closest" {
  let mut world = HitableList::new()
  let s1 = Sphere::new(center=Vec3::new(x=0.0, y=0.0, z=-1.0), radius=0.5, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let s2 = Sphere::new(center=Vec3::new(x=0.0, y=0.0, z=-2.0), radius=0.5, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  world = world.add(Hitable::Sphere(s1))
  world = world.add(Hitable::Sphere(s2))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = world.hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(rec) => assert_true(rec.t < 1.0) }
}
