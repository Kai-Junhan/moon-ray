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

ALL_SCENES = [
    "three_spheres", "cornell_box", "material_showcase", "random_spheres",
    "geometric", "cornell_box_planes", "texture_demo", "triangle_demo",
    "final_demo", "full_geometry", "studio_lighting", "depth_of_field",
    "foggy_scene", "mirror_corridor", "crystal_garden", "sunrise_valley",
    "prism_lab", "city_at_night",
]


class RenderHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/") or "/"

        if path in ("/", "/index.html"):
            self.serve_file("index.html", "text/html")
        elif path == "/style.css":
            self.serve_file("style.css", "text/css")
        elif path == "/app.js":
            self.serve_file("app.js", "application/javascript")
        elif path == "/api/scenes":
            self.serve_json({"scenes": ALL_SCENES})
        elif path == "/api/render":
            self.handle_render_get(parsed)
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path == "/api/render":
            self.handle_render_post()
        else:
            self.send_error(404)

    def handle_render_get(self, parsed):
        params = parse_qs(parsed.query)
        scene = params.get("scene", ["three_spheres"])[0]
        width = int(params.get("width", ["400"])[0])
        height = int(params.get("height", ["225"])[0])
        samples = int(params.get("samples", ["100"])[0])
        self.run_render(scene, width, height, samples, 50)

    def handle_render_post(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        try:
            data = json.loads(body)
        except Exception:
            data = {}
        scene = data.get("scene", "three_spheres")
        width = int(data.get("width", 400))
        height = int(data.get("height", 225))
        samples = int(data.get("samples", 100))
        max_depth = int(data.get("max_depth", 50))
        self.run_render(scene, width, height, samples, max_depth)

    def run_render(self, scene, width, height, samples, max_depth):
        scene_func = f"{scene}_scene"
        self.log_message("Rendering: %s, %dx%d, %d spp", scene, width, height, samples)

        # Build a complete self-contained moonbit file in a temp dir
        tmp_dir = tempfile.mkdtemp(prefix="moonray_gui_")

        src = f"""
fn main {{
  let (world, cam) = @lib.{scene_func}()
  let w = {width}
  let h = {height}
  let pixels = @lib.render_scene_full(
    width=w, height=h,
    samples_per_pixel={samples}, max_depth={max_depth},
    world=world, cam=cam,
  )
  @lib.write_ppm_tonemapped(width=w, height=h, pixels=pixels)
}}
"""
        main_path = os.path.join(tmp_dir, "main.mbt")
        with open(main_path, "w") as f:
            f.write(src)

        # Create moon.pkg
        pkg_content = 'import { "Kai-Junhan/moon-ray" @lib }\n\noptions( "is-main": true )\n'
        pkg_path = os.path.join(tmp_dir, "moon.pkg")
        with open(pkg_path, "w") as f:
            f.write(pkg_content)

        # Run via moon run in the temp dir, using moon-ray as a dependency
        try:
            # Use -C to set the directory, passing stdin for path resolution
            env = os.environ.copy()
            env["MOON_PATH"] = MOON_RAY_DIR

            # Simple approach: run the existing cmd/main but pass params via env
            # Since MoonBit doesn't support cmdline args in main(), we use the generated file
            # as a standalone project.
            # For now, we use the temp dir and moon run with relative path resolution.

            # Copy a moon.mod.json or use mooncakes dependency mechanism
            # Simplest: compile the temp file using moonc directly

            # Write a temp moon.mod
            mod_content = 'name = "temp_render"\nversion = "0.1.0"\n'
            mod_path = os.path.join(tmp_dir, "moon.mod")
            with open(mod_path, "w") as f:
                f.write(mod_content)

            result = subprocess.run(
                ["moon", "run", tmp_dir],
                capture_output=True, text=True, timeout=300,
                cwd=MOON_RAY_DIR,
            )

            # Filter moon build output lines
            ppm_lines = [
                l for l in result.stdout.split("\n")
                if l and not l.startswith("moon:") and not l.startswith("Running") and not l.startswith("Finished")
            ]
            ppm_data = "\n".join(ppm_lines)

            if "P3" in ppm_data[:50]:
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(ppm_data.encode())
            else:
                raise RuntimeError(f"No PPM data: {ppm_data[:200]}")

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
    server = http.server.HTTPServer(("", PORT), RenderHandler)
    print("=" * 60)
    print("  moon-ray GUI Server")
    print(f"  Open: http://localhost:{PORT}")
    print("=" * 60)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        server.server_close()


if __name__ == "__main__":
    main()
