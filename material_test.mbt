test "material_emissive" {
  let mat = Material::Emissive(Vec3::new(x=4.0, y=4.0, z=4.0))
  let emitted = mat.emitted(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(emitted.x, 4.0)
}
test "material_diffuse_light" {
  let mat = Material::DiffuseLight(Texture::Solid(Vec3::new(x=2.0, y=1.0, z=0.5)))
  let emitted = mat.emitted(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(emitted.x, 2.0)
}
test "texture_solid" {
  let tex = Texture::Solid(Vec3::new(x=0.1, y=0.2, z=0.3))
  let c = tex.value(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(c.x, 0.1)
}
test "tone_mapping_reinhard" {
  let bright = Vec3::new(x=10.0, y=10.0, z=10.0)
  let mapped = reinhard_tone_map(bright)
  assert_true(mapped.x < 1.1)
}
test "scene_create" {
  let mut objs = scene_empty()
  objs = scene_add_sphere(objs, center=Vec3::new(x=0.0, y=0.0, z=0.0), radius=1.0, material="lambertian", param1=0.8, param2=0.2, param3=0.2)
  assert_eq(objs.length(), 1)
}
test "render_config" {
  let cfg = default_render_config()
  assert_eq(cfg.scene, "three_spheres")
  assert_eq(cfg.width, 400)
}
test "animation_keyframe" {
  let k1 = Keyframe::new(time=0.0, position=Vec3::new(x=0.0, y=0.0, z=0.0), lookat=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let k2 = Keyframe::new(time=1.0, position=Vec3::new(x=10.0, y=0.0, z=0.0), lookat=Vec3::new(x=0.0, y=0.0, z=0.0))
  let kf = interpolate_keyframe(k1, k2, 0.5)
  assert_true((kf.position.x - 5.0).abs() < 0.01)
}
test "volume_fog" {
  let color = Vec3::new(x=1.0, y=1.0, z=1.0)
  let result = exponential_fog(color, 5.0, 0.1, Vec3::new(x=0.5, y=0.5, z=0.5))
  assert_true(result.x < 1.0)
}
test "volume_beer" {
  let color = Vec3::new(x=1.0, y=1.0, z=1.0)
  let density = Vec3::new(x=0.1, y=0.2, z=0.3)
  let result = beer_lambert_absorption(color, 2.0, density)
  assert_true(result.x > result.y)
}
