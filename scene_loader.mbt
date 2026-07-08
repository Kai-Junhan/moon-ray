///|
/// Scene description system for loading scenes from structured data.
/// Includes a simple scene builder and JSON-like scene representation.

pub(all) struct SceneObject {
  shape : String
  center : Vec3
  params : (Double, Double, Double)
  material_name : String
  material_params : (Double, Double, Double)
} derive(Debug)

pub fn make_scene_from_objects(
  objects~ : Array[SceneObject],
  cam_origin~ : Vec3,
  cam_lookat~ : Vec3,
  cam_fov~ : Double,
  cam_aspect~ : Double
) -> (HitableList, Camera) {
  let mut world = HitableList::new()

  for i in 0..<objects.length() {
    let obj = objects[i]
    let c = obj.center
    let p = obj.params

    let mat = match obj.material_name {
      "lambertian" | "diffuse" => {
        let mp = obj.material_params
        Material::Lambertian({ x: mp.0, y: mp.1, z: mp.2 })
      }
      "metal" => {
        let mp = obj.material_params
        Material::Metal({ x: mp.0, y: mp.1, z: mp.2 }, p.0)
      }
      "dielectric" | "glass" => {
        Material::Dielectric(p.0)
      }
      "emissive" | "light" => {
        let mp = obj.material_params
        Material::Emissive({ x: mp.0, y: mp.1, z: mp.2 })
      }
      "diffuselight" => {
        let mp = obj.material_params
        Material::DiffuseLight(Texture::Solid({ x: mp.0, y: mp.1, z: mp.2 }))
      }
      _ => Material::Lambertian({ x: 0.5, y: 0.5, z: 0.5 })
    }

    match obj.shape {
      "sphere" => {
        world = world.add(Hitable::Sphere(Sphere::new(
          center=c, radius=p.1, material=mat,
        )))
      }
      "box" => {
        let size = { x: p.0, y: p.1, z: p.2 }
        world = world.add(Hitable::BoxShape(BoxShape::new(
          center=c, size=size, material=mat,
        )))
      }
      "plane" => {
        let normal = { x: p.0, y: p.1, z: p.2 }
        world = world.add(Hitable::Plane(Plane::new(
          center=c, normal=normal, material=mat,
        )))
      }
      "cylinder" => {
        world = world.add(Hitable::Cylinder(Cylinder::new(
          center=c, radius=p.0, height=p.1, material=mat,
        )))
      }
      "disk" => {
        let normal = { x: p.0, y: p.1, z: p.2 }
        world = world.add(Hitable::Disk(Disk::new(
          center=c, normal=normal, radius=p.1, material=mat,
        )))
      }
      _ => ()
    }
  }

  let cam = Camera::new(
    lookfrom=cam_origin,
    lookat=cam_lookat,
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=cam_fov,
    aspect_ratio=cam_aspect,
    aperture=0.0,
    focus_dist=1.0,
    time0=0.0,
    time1=0.0,
  )

  (world, cam)
}

pub fn scene_empty() -> Array[SceneObject] {
  Array::new(capacity=32)
}

pub fn scene_add_sphere(
  objects : Array[SceneObject],
  center~ : Vec3,
  radius~ : Double,
  material~ : String,
  param1~ : Double,
  param2~ : Double,
  param3~ : Double
) -> Array[SceneObject] {
  let obj = {
    shape: "sphere",
    center,
    params: (0.0, radius, 0.0),
    material_name: material,
    material_params: (param1, param2, param3),
  }
  let result = objects
  result.push(obj)
  result
}

pub fn scene_add_box(
  objects : Array[SceneObject],
  center~ : Vec3,
  size~ : Vec3,
  material~ : String,
  r~ : Double,
  g~ : Double,
  b~ : Double
) -> Array[SceneObject] {
  let obj = {
    shape: "box",
    center,
    params: (size.x, size.y, size.z),
    material_name: material,
    material_params: (r, g, b),
  }
  let result = objects
  result.push(obj)
  result
}

pub fn scene_add_cylinder(
  objects : Array[SceneObject],
  center~ : Vec3,
  radius~ : Double,
  height~ : Double,
  material~ : String,
  r~ : Double,
  g~ : Double,
  b~ : Double
) -> Array[SceneObject] {
  let obj = {
    shape: "cylinder",
    center,
    params: (radius, height, 0.0),
    material_name: material,
    material_params: (r, g, b),
  }
  let result = objects
  result.push(obj)
  result
}

pub fn scene_add_plane(
  objects : Array[SceneObject],
  center~ : Vec3,
  normal~ : Vec3,
  material~ : String,
  r~ : Double,
  g~ : Double,
  b~ : Double
) -> Array[SceneObject] {
  let obj = {
    shape: "plane",
    center,
    params: (normal.x, normal.y, normal.z),
    material_name: material,
    material_params: (r, g, b),
  }
  let result = objects
  result.push(obj)
  result
}
