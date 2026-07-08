///|
/// BMP image file output.
/// Generates uncompressed 24-bit BMP files.

fn bmp_int_to_le_bytes(val : Int) -> (Byte, Byte, Byte, Byte) {
  let b0 = ((val >> 0) & 0xFF).to_byte()
  let b1 = ((val >> 8) & 0xFF).to_byte()
  let b2 = ((val >> 16) & 0xFF).to_byte()
  let b3 = ((val >> 24) & 0xFF).to_byte()
  (b0, b1, b2, b3)
}

pub fn write_bmp_bytes(
  width~ : Int,
  height~ : Int,
  pixels~ : Array[Vec3],
  samples_per_pixel~ : Int
) -> Array[Byte] {
  let row_padding = (4 - (width * 3) % 4) % 4
  let row_size = width * 3 + row_padding
  let image_data_size = row_size * height
  let file_size = 54 + image_data_size

  let result = Array::new(capacity=file_size)

  result.push((0x42).to_byte())
  result.push((0x4D).to_byte())

  let (b0, b1, b2, b3) = bmp_int_to_le_bytes(file_size)
  result.push(b0)
  result.push(b1)
  result.push(b2)
  result.push(b3)

  result.push((0).to_byte())
  result.push((0).to_byte())
  result.push((0).to_byte())
  result.push((0).to_byte())

  let (off0, off1, off2, off3) = bmp_int_to_le_bytes(54)
  result.push(off0)
  result.push(off1)
  result.push(off2)
  result.push(off3)

  let (d0, d1, d2, d3) = bmp_int_to_le_bytes(40)
  result.push(d0)
  result.push(d1)
  result.push(d2)
  result.push(d3)

  let (w0, w1, w2, w3) = bmp_int_to_le_bytes(width)
  result.push(w0)
  result.push(w1)
  result.push(w2)
  result.push(w3)

  let (h0, h1, h2, h3) = bmp_int_to_le_bytes(height)
  result.push(h0)
  result.push(h1)
  result.push(h2)
  result.push(h3)

  result.push((1).to_byte())
  result.push((0).to_byte())

  result.push((24).to_byte())
  result.push((0).to_byte())

  for _ in 0..<24 {
    result.push((0).to_byte())
  }

  let scale = 1.0 / samples_per_pixel.to_double()

  for y_rev in 0..<height {
    let y = height - 1 - y_rev
    for x in 0..<width {
      let idx = y * width + x
      let pixel = pixels[idx]

      let r = ((pixel.x * scale).sqrt().clamp(min=0.0, max=0.999) * 256.0).to_int()
      let g = ((pixel.y * scale).sqrt().clamp(min=0.0, max=0.999) * 256.0).to_int()
      let b = ((pixel.z * scale).sqrt().clamp(min=0.0, max=0.999) * 256.0).to_int()

      result.push(b.to_byte())
      result.push(g.to_byte())
      result.push(r.to_byte())
    }
    for _ in 0..<row_padding {
      result.push((0).to_byte())
    }
  }

  result
}
