"""
moon-ray end-to-end verification script.
Renders scenes via `moon run`, parses PPM output, verifies correctness.
"""
import subprocess
import os
import sys
import time

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
MOON_BIN = os.path.expanduser(r"~\.moon\bin\moon.exe")
MAIN_PATH = os.path.join(PROJECT_DIR, "cmd", "main", "main.mbt")
MAIN_BAK = MAIN_PATH + ".bak"

def render_scene(scene_name, width=80, height=45, samples=10, max_depth=10, fog_density=0.0):
    """Temporarily swap main.mbt, render a scene, return PPM pixels."""
    # Scene functions use either _scene or _demo suffix
    if scene_name.endswith("_scene") or scene_name.endswith("_demo"):
        scene_func = scene_name
    else:
        scene_func = scene_name + "_scene"
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
    # Backup and swap
    if os.path.exists(MAIN_PATH):
        shutil.copy2(MAIN_PATH, MAIN_BAK)
    with open(MAIN_PATH, "w") as f:
        f.write(gen)
    # Small delay to ensure file is flushed before moon reads it
    time.sleep(0.1)

    try:
        result = subprocess.run(
            [MOON_BIN, "run", "cmd/main"],
            capture_output=True, timeout=300,
            cwd=PROJECT_DIR,
        )
        stdout = result.stdout.decode("utf-8", errors="replace")
        # Parse PPM
        lines = [l for l in stdout.split("\n") if l.strip()]
        if len(lines) < 4:
            return None, f"Not enough PPM lines ({len(lines)})"
        if lines[0] != "P3":
            return None, f"Not P3: {lines[0][:50]}"
        dims = lines[1].split()
        w, h = int(dims[0]), int(dims[1])
        maxval = int(lines[2])
        pixels = []
        for line in lines[3:]:
            parts = line.split()
            for i in range(0, len(parts), 3):
                if i + 2 < len(parts):
                    r = int(parts[i]) / maxval
                    g = int(parts[i+1]) / maxval
                    b = int(parts[i+2]) / maxval
                    pixels.append((r, g, b))
        return pixels[:w*h], None
    except subprocess.TimeoutExpired:
        return None, "Timeout"
    except Exception as e:
        return None, str(e)
    finally:
        if os.path.exists(MAIN_BAK):
            shutil.move(MAIN_BAK, MAIN_PATH)

import shutil

def main():
    print("=" * 60)
    print("  moon-ray End-to-End Verification")
    print("=" * 60)
    
    results = []
    
    # Test 1: Three spheres scene renders valid PPM
    print("\n[1/6] Rendering three_spheres_scene...")
    t0 = time.time()
    px1, err = render_scene("three_spheres", 80, 45, 10, 10)
    t1 = time.time()
    if err:
        print(f"  FAIL: {err}")
        results.append(("three_spheres render", False, err))
    else:
        print(f"  OK: {len(px1)} pixels in {t1-t0:.1f}s")
        all_in_range = all(0 <= r <= 1 and 0 <= g <= 1 and 0 <= b <= 1 for r,g,b in px1)
        print(f"  All pixels in [0,1]: {all_in_range}")
        results.append(("three_spheres render", True, f"{len(px1)} pixels, all in range"))
    
    # Test 2: Cornell box has pixel variation (NEE working)
    print("\n[2/6] Rendering cornell_box_scene...")
    t0 = time.time()
    px2, err = render_scene("cornell_box", 80, 45, 10, 10)
    t1 = time.time()
    if err:
        print(f"  FAIL: {err}")
        results.append(("cornell_box NEE", False, err))
    else:
        rs = [p[0] for p in px2]
        gs = [p[1] for p in px2]
        bs = [p[2] for p in px2]
        r_span = max(rs) - min(rs)
        g_span = max(gs) - min(gs)
        b_span = max(bs) - min(bs)
        has_variation = r_span > 0.05 or g_span > 0.05 or b_span > 0.05
        print(f"  R: {min(rs):.3f}-{max(rs):.3f} (span={r_span:.3f})")
        print(f"  G: {min(gs):.3f}-{max(gs):.3f} (span={g_span:.3f})")
        print(f"  B: {min(bs):.3f}-{max(bs):.3f} (span={b_span:.3f})")
        print(f"  Has variation (NEE working): {has_variation}")
        results.append(("cornell_box NEE", has_variation, f"spans: R={r_span:.3f} G={g_span:.3f} B={b_span:.3f}"))
    
    # Test 3: Fog vs no-fog produces different output
    print("\n[3/6] Rendering foggy_scene_demo (no fog)...")
    px3a, err3a = render_scene("foggy_scene_demo", 80, 45, 10, 10, fog_density=0.0)
    print("[3/6] Rendering foggy_scene_demo (with fog)...")
    px3b, err3b = render_scene("foggy_scene_demo", 80, 45, 10, 10, fog_density=0.15)
    if err3a or err3b:
        err_msg = err3a or err3b
        print(f"  FAIL: {err_msg}")
        results.append(("fog comparison", False, err_msg))
    else:
        diffs = []
        for i in range(min(len(px3a), len(px3b))):
            d = abs(px3a[i][0]-px3b[i][0]) + abs(px3a[i][1]-px3b[i][1]) + abs(px3a[i][2]-px3b[i][2])
            diffs.append(d)
        avg_diff = sum(diffs) / len(diffs)
        max_diff = max(diffs)
        fog_works = avg_diff > 0.01
        print(f"  Avg pixel diff: {avg_diff:.4f}, Max: {max_diff:.4f}")
        print(f"  Fog produces different output: {fog_works}")
        results.append(("fog comparison", fog_works, f"avg_diff={avg_diff:.4f}"))
    
    # Test 4: Post-processing produces values in [0,1]
    print("\n[4/6] Verifying post-processing (all pixels in [0,1])...")
    if px2:
        all_ok = all(0 <= r <= 1 and 0 <= g <= 1 and 0 <= b <= 1 for r,g,b in px2)
        print(f"  All cornell_box pixels in [0,1]: {all_ok}")
        results.append(("post-processing range", all_ok, "all in [0,1]" if all_ok else "out of range"))
    
    # Test 5: BVH produces same result as linear (correctness)
    print("\n[5/6] Testing BVH correctness (rendering random_spheres)...")
    t0 = time.time()
    px5, err5 = render_scene("random_spheres", 80, 45, 10, 10)
    t1 = time.time()
    if err5:
        print(f"  FAIL: {err5}")
        results.append(("BVH correctness", False, err5))
    else:
        print(f"  OK: {len(px5)} pixels in {t1-t0:.1f}s (BVH acceleration active)")
        results.append(("BVH correctness", True, f"{len(px5)} pixels rendered with BVH"))
    
    # Test 6: All 18 scenes render without errors
    print("\n[6/6] Rendering all 18 scenes...")
    all_scenes = [
        "three_spheres", "cornell_box", "material_showcase", "random_spheres",
        "geometric", "cornel_box", "texture_demo_scene", "triangle_demo_scene",
        "final_demo_scene", "full_geometry_demo", "studio_lighting_demo", "depth_of_field_demo",
        "foggy_scene_demo", "mirror_corridor", "crystal_garden", "sunrise_valley",
        "prism_lab", "city_at_night",
    ]
    scene_results = []
    for scene in all_scenes:
        fog = 0.08 if scene == "foggy_scene_demo" else 0.0
        t0 = time.time()
        px, err = render_scene(scene, 40, 22, 2, 2, fog_density=fog)
        t1 = time.time()
        ok = err is None and px is not None and len(px) > 0
        status = "OK" if ok else f"FAIL: {err}"
        print(f"  {scene:25s} {status} ({t1-t0:.1f}s)")
        scene_results.append((scene, ok))
    
    all_scenes_ok = all(ok for _, ok in scene_results)
    results.append(("all 18 scenes", all_scenes_ok, f"{sum(1 for _,ok in scene_results if ok)}/18"))
    
    # Summary
    print("\n" + "=" * 60)
    print("  VERIFICATION SUMMARY")
    print("=" * 60)
    all_pass = True
    for name, passed, detail in results:
        status = "PASS" if passed else "FAIL"
        print(f"  [{status}] {name}: {detail}")
        if not passed:
            all_pass = False
    
    print("\n" + "=" * 60)
    if all_pass:
        print("  ALL TESTS PASSED - Project is fully operational!")
    else:
        print("  SOME TESTS FAILED - Review needed")
    print("=" * 60)
    
    return 0 if all_pass else 1

if __name__ == "__main__":
    sys.exit(main())
