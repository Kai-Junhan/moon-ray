///|
/// PPM (Portable Pixmap) image output to stdout.

/// Output PPM from raw accumulated pixels (applies gamma correction internally).
pub fn write_ppm_stdout(
  width~ : Int,
  height~ : Int,
  pixels~ : Array[Vec3],
  samples_per_pixel~ : Int
) -> Unit {
  println("P3")
  println("\{width} \{height}")
  println("255")

  let scale = 1.0 / samples_per_pixel.to_double()

  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let pixel = pixels[idx]
      let r = (pixel.x * scale).sqrt().clamp(min=0.0, max=0.999)
      let g = (pixel.y * scale).sqrt().clamp(min=0.0, max=0.999)
      let b = (pixel.z * scale).sqrt().clamp(min=0.0, max=0.999)

      let ir = (256.0 * r).to_int()
      let ig = (256.0 * g).to_int()
      let ib = (256.0 * b).to_int()

      println("\{ir} \{ig} \{ib}")
    }
  }
}

/// Output PPM from already-gamma-corrected pixels (no further correction).
pub fn write_ppm_tonemapped(
  width~ : Int,
  height~ : Int,
  pixels~ : Array[Vec3]
) -> Unit {
  println("P3")
  println("\{width} \{height}")
  println("255")

  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let pixel = pixels[idx]
      let r = pixel.x.clamp(min=0.0, max=0.999)
      let g = pixel.y.clamp(min=0.0, max=0.999)
      let b = pixel.z.clamp(min=0.0, max=0.999)

      let ir = (256.0 * r).to_int()
      let ig = (256.0 * g).to_int()
      let ib = (256.0 * b).to_int()

      println("\{ir} \{ig} \{ib}")
    }
  }
}
