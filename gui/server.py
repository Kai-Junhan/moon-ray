"""moon-ray GUI Server - bridges the MoonBit renderer with a web GUI."""
import http.server
import subprocess
import json
import os
import sys
import tempfile
import shutil
from urllib.parse import urlparse, parse_qs

PORT = 8088
PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
MOON_RAY_DIR = os.path.dirname(PROJECT_DIR)


class RenderHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/") or "/"

        if path == "/" or path == "/index.html":
            self.serve_file("index.html", "text/html")
        elif path == "/style.css":
            self.serve_file("style.css", "text/css")
        elif path == "/app.js":
            self.serve_file("app.js", "application/javascript")
        elif path == "/api/scenes":
            self.serve_json({
                "scenes": [
                    "three_spheres", "cornell_box", "material_showcase",
                    "random_spheres", "geometric", "cornell_box_planes",
                    "texture_demo", "triangle_demo", "final_demo"
                ]
            })
        elif path == "/api/render":
            self.handle_render(parsed)
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path == "/api/render":
            self.handle_render_post()
        else:
            self.send_error(404)

    def handle_render(self, parsed):
        params = parse_qs(parsed.query)
        scene = params.get("scene", ["three_spheres"])[0]
        width = int(params.get("width", ["400"])[0])
        height = int(params.get("height", ["225"])[0])
        samples = int(params.get("samples", ["100"])[0])

        self.run_render(scene, width, height, samples)

    def handle_render_post(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        try:
            data = json.loads(body)
        except:
            data = {}
        scene = data.get("scene", "three_spheres")
        width = data.get("width", 400)
        height = data.get("height", 225)
        samples = data.get("samples", 100)
        max_depth = data.get("max_depth", 50)

        self.run_render(scene, width, height, samples, max_depth)

    def run_render(self, scene, width, height, samples, max_depth=50):
        self.log_message("Rendering: scene=%s, %dx%d, %d samples", scene, width, height, samples)

        tmp_dir = tempfile.mkdtemp()
        tmp_ppm = os.path.join(tmp_dir, "render.ppm")

        render_script = f"""
fn main {{
  let (world, cam) = @lib.{scene}_scene()
  let width = {width}
  let height = {height}
  let samples = {samples}
  let max_depth = {max_depth}
  let pixels = @lib.render_scene(width=width, height=height, samples_per_pixel=samples, max_depth=max_depth, world=world, cam=cam)
  @lib.write_ppm_stdout(width=width, height=height, pixels=pixels, samples_per_pixel=samples)
}}
"""

        tmp_main = os.path.join(tmp_dir, "main.mbt")
        with open(tmp_main, "w") as f:
            f.write(render_script)

        try:
            result = subprocess.run(
                ["moon", "run", MOON_RAY_DIR + "/cmd/main", "--", "--scene", scene,
                 "--width", str(width), "--height", str(height),
                 "--samples", str(samples), "--max-depth", str(max_depth)],
                capture_output=True,
                text=True,
                timeout=300,
                cwd=MOON_RAY_DIR,
            )

            ppm_lines = [l for l in result.stdout.split("\n") if l and not l.startswith("moon:")]
            ppm_data = "\n".join(ppm_lines)

            if ppm_data.startswith("P3"):
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(ppm_data.encode())
            else:
                raise RuntimeError("Invalid PPM output")

        except subprocess.TimeoutExpired:
            self.send_error(504, "Render timeout")
        except Exception as e:
            self.send_error(500, f"Render error: {str(e)}")
        finally:
            shutil.rmtree(tmp_dir, ignore_errors=True)

    def serve_file(self, filename, content_type):
        filepath = os.path.join(PROJECT_DIR, filename)
        try:
            with open(filepath, "rb") as f:
                self.send_response(200)
                self.send_header("Content-Type", content_type + "; charset=utf-8")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(f.read())
        except FileNotFoundError:
            self.send_error(404, f"File not found: {filename}")

    def serve_json(self, data):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        print(f"[GUI] {format % args}", flush=True)


def main():
    handler = RenderHandler
    server = http.server.HTTPServer(("", PORT), handler)
    print(f"=" * 60)
    print(f"  moon-ray GUI Server")
    print(f"  Open: http://localhost:{PORT}")
    print(f"=" * 60)
    print()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        server.server_close()


if __name__ == "__main__":
    main()
