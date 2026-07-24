///|
/// Render configuration and parameter management for GUI integration.

pub(all) struct PostProcessConfig {
  bloom_enabled : Bool
  bloom_threshold : Double
  bloom_intensity : Double
  color_grading_enabled : Bool
  contrast : Double
  saturation : Double
  brightness : Double
  temperature : Double
  vignette_strength : Double
} derive(Debug)

pub fn default_post_process_config() -> PostProcessConfig {
  {
    bloom_enabled: true,
    bloom_threshold: 0.8,
    bloom_intensity: 0.3,
    color_grading_enabled: true,
    contrast: 1.0,
    saturation: 1.0,
    brightness: 1.0,
    temperature: 0.0,
    vignette_strength: 0.3,
  }
}

pub(all) struct RenderConfig {
  scene : String
  width : Int
  height : Int
  samples : Int
  max_depth : Int
  output_format : String
  aperture : Double
  fov : Double
  post_process : PostProcessConfig
} derive(Debug)

pub fn default_render_config() -> RenderConfig {
  {
    scene: "three_spheres",
    width: 400,
    height: 225,
    samples: 100,
    max_depth: 50,
    output_format: "ppm",
    aperture: 0.0,
    fov: 90.0,
    post_process: default_post_process_config(),
  }
}

pub fn render_with_config(config : RenderConfig) -> (Array[Vec3], Int, Int) {
  let (world, cam) = match config.scene {
    "three_spheres" => three_spheres_scene()
    "cornell_box" => cornell_box_scene()
    "material_showcase" => material_showcase_scene()
    "random_spheres" => random_spheres_scene()
    "geometric" => geometric_scene()
    "cornell_box_planes" => cornel_box_scene()
    "texture_demo" => texture_demo_scene()
    "triangle_demo" => triangle_demo_scene()
    "final_demo" => final_demo_scene()
    "full_geometry" => full_geometry_demo()
    "studio_lighting" => studio_lighting_demo()
    "depth_of_field" => depth_of_field_demo()
    "foggy_scene" => foggy_scene_demo()
    "mirror_corridor" => mirror_corridor_scene()
    "crystal_garden" => crystal_garden_scene()
    "sunrise_valley" => sunrise_valley_scene()
    "prism_lab" => prism_lab_scene()
    "city_at_night" => city_at_night_scene()
    _ => three_spheres_scene()
  }

  let fog = if config.scene == "foggy_scene" { 0.08 } else { 0.0 }
  let w = config.width
  let h = config.height
  let pixels = render_scene_full(
    width=w, height=h,
    samples_per_pixel=config.samples,
    max_depth=config.max_depth,
    world=world, cam=cam,
    fog_density=fog,
    post_process=config.post_process,
  )
  (pixels, w, h)
}

pub fn list_scenes() -> Array[String] {
  let scenes = Array::new(capacity=20)
  let result = scenes
  result.push("three_spheres")
  result.push("cornell_box")
  result.push("material_showcase")
  result.push("random_spheres")
  result.push("geometric")
  result.push("cornell_box_planes")
  result.push("texture_demo")
  result.push("triangle_demo")
  result.push("final_demo")
  result.push("full_geometry")
  result.push("studio_lighting")
  result.push("depth_of_field")
  result.push("foggy_scene")
  result.push("mirror_corridor")
  result.push("crystal_garden")
  result.push("sunrise_valley")
  result.push("prism_lab")
  result.push("city_at_night")
  result
}
