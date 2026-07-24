test "render_full_pipeline_output" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene_full(width=4, height=4, samples_per_pixel=4, max_depth=4, world=world, cam=cam, fog_density=0.0, post_process=default_post_process_config())
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
  let pixels = render_scene_full(width=1, height=1, samples_per_pixel=1, max_depth=1, world=world, cam=cam, fog_density=0.0, post_process=default_post_process_config())
  assert_eq(pixels.length(), 1)
  assert_true(pixels[0].x >= 0.0 && pixels[0].x <= 1.0)
}
test "render_with_fog_zero" {
  let (world, cam) = three_spheres_scene()
  let pixels1 = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.0, post_process=default_post_process_config())
  let pixels2 = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.0, post_process=default_post_process_config())
  assert_eq(pixels1.length(), 4)
  assert_eq(pixels2.length(), 4)
}
test "render_with_fog_enabled" {
  let (world, cam) = foggy_scene_demo()
  let pixels = render_scene_full(width=2, height=2, samples_per_pixel=2, max_depth=2, world=world, cam=cam, fog_density=0.1, post_process=default_post_process_config())
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
  let pixels = render_scene_full(width=8, height=6, samples_per_pixel=4, max_depth=4, world=world, cam=cam, fog_density=0.0, post_process=default_post_process_config())
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
  let pp = { ..default_post_process_config(), bloom_enabled: false, color_grading_enabled: false }
  let no_fog = render_scene_full(width=4, height=4, samples_per_pixel=2, max_depth=4, world=w, cam=cam, fog_density=0.0, post_process=pp)
  let with_fog = render_scene_full(width=4, height=4, samples_per_pixel=2, max_depth=4, world=w, cam=cam, fog_density=0.15, post_process=pp)
  assert_eq(no_fog.length(), 16)
  assert_eq(with_fog.length(), 16)
  // Fog attenuates scene toward fog color — measure actual difference
  let mut total_diff = 0.0
  for k in 0..<16 {
    total_diff = total_diff + (no_fog[k].x - with_fog[k].x).abs() + (no_fog[k].y - with_fog[k].y).abs() + (no_fog[k].z - with_fog[k].z).abs()
  }
  assert_true(total_diff > 0.1)
}

test "bloom_brightens_highlights" {
  let pixels = Array::new(capacity=4)
  // One bright pixel, three dark
  pixels.push(Vec3::new(x=0.95, y=0.95, z=0.95))
  pixels.push(Vec3::new(x=0.1, y=0.1, z=0.1))
  pixels.push(Vec3::new(x=0.1, y=0.1, z=0.1))
  pixels.push(Vec3::new(x=0.1, y=0.1, z=0.1))
  let result = apply_bloom(pixels, 2, 2, threshold=0.8, intensity=0.5)
  // Bloom should add energy: neighbors of bright pixel get brighter
  assert_true(result[1].x > 0.1)
  // The bright pixel itself stays at or above its original luminance
  assert_true(result[0].x >= 0.9)
}

test "color_grading_contrast_changes_midtones" {
  let pixels = Array::new(capacity=1)
  pixels.push(Vec3::new(x=0.3, y=0.3, z=0.3))
  let high_contrast = apply_color_grading(pixels, 1, 1, contrast=2.0, saturation=1.0, brightness=1.0, temperature=0.0)
  let low_contrast = apply_color_grading(pixels, 1, 1, contrast=0.5, saturation=1.0, brightness=1.0, temperature=0.0)
  assert_true(high_contrast[0].x != low_contrast[0].x)
}

test "vignette_darkens_corners" {
  let pixels = Array::new(capacity=16)
  for _ in 0..<16 {
    pixels.push(Vec3::new(x=1.0, y=1.0, z=1.0))
  }
  let result = apply_vignette(pixels, 4, 4, strength=0.5)
  // Corner pixels (0,0), (3,0), (0,3), (3,3) must be darkened
  assert_true(result[0].x < 1.0)
  assert_true(result[3].x < 1.0)
  assert_true(result[12].x < 1.0)
  assert_true(result[15].x < 1.0)
}

test "nee_contributes_direct_light" {
  let (world, cam) = three_spheres_scene()
  let w = world.build_bvh()
  let pp = { ..default_post_process_config(), bloom_enabled: false, color_grading_enabled: false }
  let pixels = render_scene_full(width=4, height=4, samples_per_pixel=4, max_depth=4, world=w, cam=cam, fog_density=0.0, post_process=pp)
  let mut max_lum = 0.0
  for k in 0..<pixels.length() {
    let lum = pixels[k].x * 0.2126 + pixels[k].y * 0.7152 + pixels[k].z * 0.0722
    if lum > max_lum { max_lum = lum }
  }
  assert_true(max_lum > 0.001)
}

test "volume_ray_march_attenuates" {
  let vol = VolumeBox::new(
    min_point=Vec3::new(x=-1.0, y=-1.0, z=-1.0),
    max_point=Vec3::new(x=1.0, y=1.0, z=1.0),
    density=2.0,
    albedo=Vec3::new(x=0.5, y=0.5, z=0.5),
  )
  let ray = Ray::new(orig=Vec3::new(x=0.0, y=0.0, z=-3.0), dir=Vec3::new(x=0.0, y=0.0, z=1.0))
  let (emitted, transmittance) = ray_march_volume(vol, ray, 0.001, 100.0)
  // Ray passes through volume: transmittance should be < 1
  assert_true(transmittance < 1.0)
  assert_true(transmittance > 0.0)
  // Volume should emit some light based on albedo
  assert_true(emitted.x > 0.0)
}

test "bvh_matches_linear_scan" {
  let (world, _cam) = material_showcase_scene()
  let w_bvh = world.build_bvh()
  let ray = Ray::new(orig=Vec3::new(x=0.0, y=1.0, z=5.0), dir=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let hit_linear = world.hit_linear(ray, t_min=0.001, t_max=1.0e30)
  let hit_bvh = w_bvh.hit(ray, t_min=0.001, t_max=1.0e30)
  match (hit_linear, hit_bvh) {
    (Some(r1), Some(r2)) => assert_true((r1.t - r2.t).abs() < 0.001)
    (None, None) => ()
    _ => assert_true(false)
  }
}

test "russian_roulette_preserves_energy" {
  // With enough samples, Russian roulette should not bias the result
  let (world, cam) = three_spheres_scene()
  let w = world.build_bvh()
  let pp = { ..default_post_process_config(), bloom_enabled: false, color_grading_enabled: false }
  // Low depth (no RR) vs high depth (RR active for depth > 3)
  let shallow = render_scene_full(width=2, height=2, samples_per_pixel=4, max_depth=3, world=w, cam=cam, fog_density=0.0, post_process=pp)
  let deep = render_scene_full(width=2, height=2, samples_per_pixel=4, max_depth=10, world=w, cam=cam, fog_density=0.0, post_process=pp)
  // Deep should have at least as much energy as shallow (more bounces = more light)
  let mut sum_shallow = 0.0
  let mut sum_deep = 0.0
  for k in 0..<4 {
    sum_shallow = sum_shallow + shallow[k].x + shallow[k].y + shallow[k].z
    sum_deep = sum_deep + deep[k].x + deep[k].y + deep[k].z
  }
  // Deep render with more bounces should accumulate at least as much light
  assert_true(sum_deep >= sum_shallow * 0.8)
}
