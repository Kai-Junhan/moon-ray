test "material_emissive_emits" {
  let mat = Material::Emissive(Vec3::new(x=4.0, y=0.0, z=0.0))
  let e = mat.emitted(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(e.x, 4.0)
  assert_eq(e.y, 0.0)
}
test "material_diffuse_light_emits" {
  let mat = Material::DiffuseLight(Texture::Solid(Vec3::new(x=2.0, y=1.0, z=0.5)))
  let e = mat.emitted(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(e.x, 2.0)
  assert_eq(e.y, 1.0)
}
test "material_lambertian_has_scatter" {
  let mat = Material::Lambertian(Vec3::new(x=0.8, y=0.2, z=0.2))
  assert_eq(mat.albedo_at(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0)).x, 0.8)
}
test "material_metal_albedo" {
  let mat = Material::Metal(Vec3::new(x=0.9, y=0.1, z=0.1), 0.05)
  assert_eq(mat.albedo_at(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0)).x, 0.9)
}
test "texture_solid_value" {
  let tex = Texture::Solid(Vec3::new(x=0.1, y=0.2, z=0.3))
  let c = tex.value(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_eq(c.x, 0.1)
  assert_eq(c.y, 0.2)
  assert_eq(c.z, 0.3)
}
test "texture_checker_produces_both_sides" {
  let even = Texture::Solid(Vec3::new(x=1.0, y=0.0, z=0.0))
  let odd = Texture::Solid(Vec3::new(x=0.0, y=0.0, z=1.0))
  let tex = Texture::Checker(even, odd, 2.0)
  let c1 = tex.value(0.0, 0.0, Vec3::new(x=0.5, y=0.5, z=0.5))
  let c2 = tex.value(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
  assert_true(c1.x == 1.0 || c1.z == 1.0 || c2.x == 1.0 || c2.z == 1.0)
}
test "tone_mapping_reinhard_dims" {
  let bright = Vec3::new(x=10.0, y=10.0, z=10.0)
  let mapped = reinhard_tone_map(bright)
  assert_true(mapped.x < 1.1 && mapped.y > 0.8)
}
test "tone_mapping_aces_in_range" {
  let bright = Vec3::new(x=5.0, y=5.0, z=5.0)
  let mapped = aces_tone_map(bright)
  assert_true(mapped.x < 1.05 && mapped.x > 0.0)
}
test "gamma_correct_brightens_midtone" {
  let c = Vec3::new(x=0.5, y=0.5, z=0.5)
  let g = gamma_correct(c, 2.2)
  assert_true(g.x > 0.5 && g.x < 1.0)
}
test "exposure_adjust_doubles" {
  let c = Vec3::new(x=0.5, y=0.5, z=0.5)
  let e = exposure_adjust(c, 1.0)
  assert_true((e.x - 1.0).abs() < 0.01)
}
test "scene_create_sphere" {
  let mut objs = scene_empty()
  objs = scene_add_sphere(objs, center=Vec3::new(x=0.0, y=0.0, z=0.0), radius=1.0, material="lambertian", param1=0.8, param2=0.2, param3=0.2)
  assert_eq(objs.length(), 1)
}
test "scene_create_box" {
  let mut objs = scene_empty()
  objs = scene_add_box(objs, center=Vec3::new(x=2.0, y=0.0, z=0.0), size=Vec3::new(x=1.0, y=1.0, z=1.0), material="metal", r=0.9, g=0.9, b=0.9)
  assert_eq(objs.length(), 1)
}
test "render_config_defaults" {
  let cfg = default_render_config()
  assert_eq(cfg.scene, "three_spheres")
  assert_eq(cfg.width, 400)
  assert_eq(cfg.height, 225)
  assert_eq(cfg.samples, 100)
  assert_eq(cfg.max_depth, 50)
}
test "animation_keyframe_midpoint" {
  let k1 = Keyframe::new(time=0.0, position=Vec3::new(x=0.0, y=0.0, z=0.0), lookat=Vec3::new(x=0.0, y=0.0, z=-1.0))
  let k2 = Keyframe::new(time=1.0, position=Vec3::new(x=10.0, y=0.0, z=0.0), lookat=Vec3::new(x=0.0, y=0.0, z=0.0))
  let kf = interpolate_keyframe(k1, k2, 0.5)
  assert_true((kf.position.x - 5.0).abs() < 0.01)
}
test "volume_fog_diminishes_color" {
  let color = Vec3::new(x=1.0, y=1.0, z=1.0)
  let result = exponential_fog(color, 5.0, 0.1, Vec3::new(x=0.5, y=0.5, z=0.5))
  assert_true(result.x < 1.0 && result.x > 0.0)
}
test "volume_beer_lambert_channel_diff" {
  let color = Vec3::new(x=1.0, y=1.0, z=1.0)
  let density = Vec3::new(x=0.1, y=0.2, z=0.3)
  let result = beer_lambert_absorption(color, 2.0, density)
  assert_true(result.x > result.y)
  assert_true(result.y > result.z)
}
test "easing_quad_endpoints" {
  assert_eq(ease_in_out_quad(0.0), 0.0)
  assert_eq(ease_in_out_quad(1.0), 1.0)
}
test "easing_cubic_endpoints" {
  assert_eq(ease_in_out_cubic(0.0), 0.0)
}
test "motion_blur_returns_duration" {
  let (t, dur) = motion_blur_sample(0.0, 1.0)
  assert_true(t >= 0.0 && t < 1.0)
  assert_eq(dur, 1.0)
}
test "catmull_rom_interpolates" {
  let v0 = Vec3::new(x=0.0, y=0.0, z=0.0)
  let v1 = Vec3::new(x=1.0, y=1.0, z=0.0)
  let v2 = Vec3::new(x=2.0, y=0.0, z=0.0)
  let v3 = Vec3::new(x=3.0, y=1.0, z=0.0)
  let p = catmull_rom(v0, v1, v2, v3, 0.5)
  assert_true(p.x > 0.8 && p.x < 2.2)
}
test "orbit_path_length" {
  let path = create_orbiting_camera_path(
    center=Vec3::new(x=0.0, y=0.0, z=0.0),
    radius=5.0, height=3.0, num_frames=4, duration=3.0,
  )
  assert_eq(path.length(), 4)
}
test "mesh_cube_has_triangles" {
  let mesh = Mesh::build_cube(center=Vec3::new(x=0.0, y=0.0, z=0.0), size=2.0, material=Material::Lambertian(Vec3::new(x=0.5, y=0.5, z=0.5)))
  let world = mesh_to_hitable_list(mesh)
  assert_true(world.objects.length() >= 12)
}
test "mesh_uv_sphere_has_vertices" {
  let mesh = Mesh::build_uv_sphere(center=Vec3::new(x=0.0, y=0.0, z=-2.0), radius=1.0, segments=8, rings=4, material=Material::Dielectric(1.5))
  assert_true(mesh.vertices.length() > 20)
}
test "bmp_header_magic_bytes" {
  let pixels = Array::new(capacity=1)
  pixels.push(Vec3::new(x=0.5, y=0.5, z=0.5))
  let bytes = write_bmp_bytes(width=1, height=1, pixels=pixels, samples_per_pixel=1)
  assert_eq(bytes[0].to_int(), 0x42)
  assert_eq(bytes[1].to_int(), 0x4D)
}
test "sobol_in_range" {
  let s = sobol_sample(123, 3)
  assert_true(s >= 0.0 && s < 1.0)
}
test "environment_sky_color" {
  let env = Environment::default_sky()
  let up = env.sample(Vec3::new(x=0.0, y=1.0, z=0.0))
  assert_true(up.z > 0.0 || up.y > 0.0)
}
test "black_body_cool_blue" {
  let warm = black_body_radiation(3000.0)
  let cool = black_body_radiation(10000.0)
  assert_true(cool.z > warm.z)
}
test "sun_direction_above_horizon" {
  let d = sun_direction(0.25)
  assert_true(d.y > 0.0)
}
test "layered_fog_near_ground" {
  let color = Vec3::new(x=1.0, y=1.0, z=1.0)
  let result = layered_fog(color, 0.0, 0.0, 10.0, 0.5, Vec3::new(x=0.5, y=0.5, z=0.5))
  assert_true(result.x > 0.0 && result.x <= 1.0)
}
