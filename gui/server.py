"""moon-ray GUI Server — renders scenes and serves PPM to the browser."""
import http.server
import subprocess
import json
import os
import shutil
import tempfile
import threading
from urllib.parse import urlparse

PORT = 8088
PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
MOON_RAY_DIR = os.path.dirname(PROJECT_DIR)
MAIN_PATH = os.path.join(MOON_RAY_DIR, "cmd", "main", "main.mbt")
MAIN_BAK = MAIN_PATH + ".bak"

ALL_SCENES = [
    "three_spheres", "cornell_box", "material_showcase", "random_spheres",
    "geometric", "cornell_box_planes", "texture_demo", "triangle_demo",
    "final_demo", "full_geometry", "studio_lighting", "depth_of_field",
    "foggy_scene", "mirror_corridor", "crystal_garden", "sunrise_valley",
    "prism_lab", "city_at_night",
]

_render_lock = threading.Lock()


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
            self.send_error(405)
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path == "/api/render":
            self.handle_render()
        else:
            self.send_error(404)

    def handle_render(self):
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

        if scene not in ALL_SCENES:
            scene = "three_spheres"

        self.log_message("Render: scene=%s %dx%d %dspp", scene, width, height, samples)
        self.try_render(scene, width, height, samples, max_depth)

    def try_render(self, scene, width, height, samples, max_depth):
        fog_density = 0.08 if scene == "foggy_scene" else 0.0
        scene_func = scene + "_scene"
        gen = f"""fn main {{
  let (world, cam) = @lib.{scene_func}()
  let pixels = @lib.render_scene_full(
    width={width}, height={height},
    samples_per_pixel={samples}, max_depth={max_depth},
    world=world, cam=cam,
    fog_density={fog_density},
  )
  @lib.write_ppm_tonemapped(width={width}, height={height}, pixels=pixels)
}}
"""
        with _render_lock:
            try:
                if os.path.exists(MAIN_PATH):
                    shutil.copy2(MAIN_PATH, MAIN_BAK)
                with open(MAIN_PATH, "w") as f:
                    f.write(gen)

                result = subprocess.run(
                    ["moon", "run", "cmd/main"],
                    capture_output=True, text=True, timeout=300,
                    cwd=MOON_RAY_DIR,
                )
                ppm_lines = [
                    l for l in result.stdout.split("\n")
                    if l and "moon:" not in l and "Running" not in l and "Finished" not in l
                ]
                ppm_data = "\n".join(ppm_lines)

                if "P3" in ppm_data[:50]:
                    self.send_response(200)
                    self.send_header("Content-Type", "text/plain")
                    self.send_header("Access-Control-Allow-Origin", "*")
                    self.end_headers()
                    self.wfile.write(ppm_data.encode())
                else:
                    raise RuntimeError(f"No PPM output. Got: {ppm_data[:200]}")
            except subprocess.TimeoutExpired:
                self.send_error(504, "Render timed out")
            except Exception as e:
                self.send_error(500, f"Render error: {str(e)}")
            finally:
                if os.path.exists(MAIN_BAK):
                    shutil.move(MAIN_BAK, MAIN_PATH)

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
            self.send_error(404)

    def serve_json(self, data):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, fmt, *args):
        print(f"[GUI] {fmt % args}", flush=True)


def main():
    server = http.server.HTTPServer(("", PORT), RenderHandler)
    print("=" * 60)
    print("  moon-ray GUI Server")
    print(f"  http://localhost:{PORT}")
    print("=" * 60)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        if os.path.exists(MAIN_BAK):
            shutil.move(MAIN_BAK, MAIN_PATH)
        server.server_close()


if __name__ == "__main__":
    main()
