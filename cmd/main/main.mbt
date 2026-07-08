fn main {
  let scene_name = "three_spheres"
  let width = 400
  let height = 225
  let samples = 100
  let max_depth = 50

  let (world, cam) = match scene_name {
    "three_spheres" => @lib.three_spheres_scene()
    "cornell_box" => @lib.cornell_box_scene()
    "material_showcase" => @lib.material_showcase_scene()
    "random_spheres" => @lib.random_spheres_scene()
    "geometric" => @lib.geometric_scene()
    "cornell_box_planes" => @lib.cornel_box_scene()
    "texture_demo" => @lib.texture_demo_scene()
    "triangle_demo" => @lib.triangle_demo_scene()
    "final_demo" => @lib.final_demo_scene()
    "full_geometry" => @lib.full_geometry_demo()
    "studio_lighting" => @lib.studio_lighting_demo()
    "depth_of_field" => @lib.depth_of_field_demo()
    "foggy_scene" => @lib.foggy_scene_demo()
    "mirror_corridor" => @lib.mirror_corridor_scene()
    "crystal_garden" => @lib.crystal_garden_scene()
    "sunrise_valley" => @lib.sunrise_valley_scene()
    "prism_lab" => @lib.prism_lab_scene()
    "city_at_night" => @lib.city_at_night_scene()
    _ => @lib.three_spheres_scene()
  }

  let pixels = @lib.render_scene(width=width, height=height, samples_per_pixel=samples, max_depth=max_depth, world=world, cam=cam)
  @lib.write_ppm_stdout(width=width, height=height, pixels=pixels, samples_per_pixel=samples)
}
