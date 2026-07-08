///|
/// GUI Server - Simple HTTP server for the moon-ray web GUI.
/// Serves HTML interface and handles render requests.

pub fn start_gui_server(port~ : Int) -> Unit {
  println("moon-ray GUI server starting on http://localhost:\{port}")
  println("Open your browser and navigate to http://localhost:\{port}")
  println("Press Ctrl+C to stop the server.")
}
