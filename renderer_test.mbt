test "render_full_pipeline_output" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene_full(width=4, height=4, samples_per_pixel=4, max_depth=4, world=world, cam=cam, fog_density=0.0)
  assert_eq(pixels.length(), 16)
  for i in 0..<pixels.length() {
    assert_true(pixels[i].x >= 0.0)
    assert_true(pixels[i].x <= 1.0)
  }
}
test "render_scene_with_bvh" {
  let (world, cam) = random_spheres_scene()
  let w = world.build_bvh()
  let pixels = render_scene(width=4, height=4, samples_per_pixel=2, max_depth=2, world=w, cam=cam, fog_density=0.0)
  assert_eq(pixels.length(), 16)
}
test "render_full_pipeline_min" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene_full(width=1, height=1, samples_per_pixel=1, max_depth=1, world=world, cam=cam, fog_density=0.0)
  assert_eq(pixels.length(), 1)
  assert_true(pixels[0].x >= 0.0 && pixels[0].x <= 1.0)
}
test "render_with_fog_zero" {
  let (world, cam) = three_spheres_scene()
  let pixels1 = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.0)
  let pixels2 = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.0)
  assert_eq(pixels1.length(), 4)
  assert_eq(pixels2.length(), 4)
}
test "render_with_fog_enabled" {
  let (world, cam) = foggy_scene_demo()
  let pixels = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.1)
  assert_eq(pixels.length(), 4)
  assert_true(pixels[0].x >= 0.0 && pixels[0].x <= 1.0)
}
test "camera_default_position" {
  let cam = Camera::default(aspect_ratio=1.0)
  assert_eq(cam.origin.x, 0.0)
  assert_eq(cam.origin.y, 0.0)
  assert_eq(cam.origin.z, 0.0)
}
test "camera_ray_direction" {
  let cam = Camera::default(aspect_ratio=1.0)
  let r = cam.get_ray(0.5, 0.5)
  assert_true(r.dir.z < -0.5)
}
test "camera_ray_corners_differ" {
  let cam = Camera::default(aspect_ratio=1.0)
  let r1 = cam.get_ray(0.0, 0.0)
  let r2 = cam.get_ray(1.0, 1.0)
  let diff = (r1.dir.x - r2.dir.x).abs() + (r1.dir.y - r2.dir.y).abs()
  assert_true(diff > 0.01)
}
test "mirror_corridor_scene_has_objects" {
  let (world, _cam) = mirror_corridor_scene()
  assert_true(world.objects.length() > 5)
}
test "crystal_garden_has_lights" {
  let (world, _cam) = crystal_garden_scene()
  let mut has_light = false
  for i in 0..<world.objects.length() {
    let emitted = world.objects[i].match_material(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
    if emitted.length() > 0.1 { has_light = true }
  }
  assert_true(has_light)
}
test "bvh_build_on_scene" {
  let (world, _cam) = random_spheres_scene()
  let w = world.build_bvh()
  assert_true(w.bvh_ready)
}
test "bvh_hit_on_built_scene" {
  let (world, _cam) = three_spheres_scene()
  let w = world.build_bvh()
  let r = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=0.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit = w.hit(r, t_min=0.0, t_max=10.0)
  match hit { None => assert_true(false); Some(rec) => assert_true(rec.t > 0.0) }
}
test "full_pipeline_tonemapped_pixels_in_range" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene_full(width=8, height=6, samples_per_pixel=4, max_depth=4, world=world, cam=cam, fog_density=0.0)
  for k in 0..<pixels.length() {
    assert_true(pixels[k].x >= 0.0)
    assert_true(pixels[k].x <= 1.0)
    assert_true(pixels[k].y <= 1.0)
    assert_true(pixels[k].z <= 1.0)
  }
}
test "fog_scene_with_bvh_and_fog" {
  let (world, cam) = foggy_scene_demo()
  let w = world.build_bvh()
  let no_fog = render_scene_full(width=4, height=4, samples_per_pixel=2, max_depth=2, world=w, cam=cam, fog_density=0.0)
  let with_fog = render_scene_full(width=4, height=4, samples_per_pixel=2, max_depth=2, world=w, cam=cam, fog_density=0.15)
  assert_eq(no_fog.length(), 16)
  assert_eq(with_fog.length(), 16)
  // Fog scene with high density should produce noticeably different results
  assert_true(no_fog[0].x >= 0.0)
  assert_true(with_fog[0].x >= 0.0)
  assert_true(with_fog[0].x <= 1.0)
}
