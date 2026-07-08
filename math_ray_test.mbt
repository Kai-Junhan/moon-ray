test "ray_at" {
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=1.0, y=0.0, z=0.0))
  let p = r.at(5.0)
  assert_eq(p.x, 5.0)
}
test "aabb_hit" {
  let box = AABB::new(min=Vec3::new(x=-1.0, y=-1.0, z=-1.0), max=Vec3::new(x=1.0, y=1.0, z=1.0))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=-2.0), dir=Vec3::new(x=0.0, y=0.0, z=1.0))
  assert_true(box.hit(r, t_min=0.0, t_max=10.0))
}
test "aabb_miss" {
  let box = AABB::new(min=Vec3::new(x=-1.0, y=-1.0, z=-1.0), max=Vec3::new(x=1.0, y=1.0, z=1.0))
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=-2.0), dir=Vec3::new(x=1.0, y=0.0, z=0.0))
  assert_true(!(box.hit(r, t_min=0.0, t_max=10.0)))
}
test "rng_random" {
  let rng = new_rng(42UL)
  let (v, _) = rng.random_double()
  assert_true(v >= 0.0)
  assert_true(v < 1.0)
}
test "rng_unit_vector" {
  let rng = new_rng(42UL)
  let (v, _) = rng.random_unit_vector()
  assert_true((v.length() - 1.0).abs() < 0.01)
}
test "onb_basic" {
  let n = Vec3::new(x=0.0, y=1.0, z=0.0)
  let onb = ONB::build_from_w(normal=n)
  assert_true(onb.w.y.abs() > 0.9)
}
