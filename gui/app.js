/**
 * moon-ray GUI - Frontend Application
 * Handles scene selection, render triggering, and PPM display.
 */

class MoonRayApp {
  constructor() {
    this.canvas = document.getElementById('render-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.placeholder = document.getElementById('placeholder');
    this.statusEl = document.getElementById('status');
    this.renderBtn = document.getElementById('render-btn');
    this.stopBtn = document.getElementById('stop-btn');
    this.samplesInput = document.getElementById('samples-input');
    this.depthInput = document.getElementById('depth-input');
    this.fogInput = document.getElementById('fog-input');
    this.abortController = null;

    this.bindEvents();
    this.loadScenes();
  }

  bindEvents() {
    this.renderBtn.addEventListener('click', () => this.startRender());
    this.stopBtn.addEventListener('click', () => this.stopRender());

    this.samplesInput.addEventListener('input', () => {
      document.getElementById('samples-val').textContent = this.samplesInput.value;
    });
    this.depthInput.addEventListener('input', () => {
      document.getElementById('depth-val').textContent = this.depthInput.value;
    });
    this.fogInput.addEventListener('input', () => {
      document.getElementById('fog-val').textContent = parseFloat(this.fogInput.value).toFixed(2);
    });

    document.querySelectorAll('.preset-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.getElementById('width-input').value = btn.dataset.w;
        document.getElementById('height-input').value = btn.dataset.h;
        this.samplesInput.value = btn.dataset.s;
        document.getElementById('samples-val').textContent = btn.dataset.s;
      });
    });
  }

  loadScenes() {
    fetch('/api/scenes')
      .then(r => r.json())
      .then(data => {
        const sel = document.getElementById('scene-select');
        sel.innerHTML = data.scenes.map(s =>
          `<option value="${s}">${this.formatSceneName(s)}</option>`
        ).join('');
      })
      .catch(() => {});
  }

  formatSceneName(name) {
    return name.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
  }

  async startRender() {
    this.abortController = new AbortController();

    const scene = document.getElementById('scene-select').value;
    const width = parseInt(document.getElementById('width-input').value);
    const height = parseInt(document.getElementById('height-input').value);
    const samples = parseInt(this.samplesInput.value);
    const maxDepth = parseInt(this.depthInput.value);
    const fogDensity = parseFloat(this.fogInput.value);

    this.setStatus('Rendering...', 'status-rendering');
    this.renderBtn.disabled = true;
    this.stopBtn.disabled = false;
    this.placeholder.style.display = 'none';
    this.canvas.style.display = 'block';

    const startTime = performance.now();

    try {
      const response = await fetch('/api/render', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ scene, width, height, samples, maxDepth, fog_density: fogDensity }),
        signal: this.abortController.signal,
      });

      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const ppmText = await response.text();
      this.displayPPM(ppmText, width, height);

      const elapsed = ((performance.now() - startTime) / 1000).toFixed(1);
      this.setStatus(`Done in ${elapsed}s`, 'status-done');
      document.getElementById('render-time').textContent =
        `Render: ${elapsed}s | ${width}x${height} | ${samples} samples`;
    } catch (err) {
      if (err.name !== 'AbortError') {
        this.setStatus('Error: ' + err.message, 'status-error');
      } else {
        this.setStatus('Stopped', 'status-idle');
      }
    } finally {
      this.renderBtn.disabled = false;
      this.stopBtn.disabled = true;
      this.abortController = null;
    }
  }

  stopRender() {
    if (this.abortController) {
      this.abortController.abort();
    }
  }

  displayPPM(ppmText, width, height) {
    this.canvas.width = width;
    this.canvas.height = height;

    const lines = ppmText.trim().split('\n');
    let dataStart = 0;
    if (lines[0] === 'P3') {
      let headerDone = 0;
      for (let i = 0; i < lines.length; i++) {
        if (!lines[i].startsWith('#') && lines[i].trim() !== '') {
          headerDone++;
          if (headerDone >= 3) {
            dataStart = i;
            break;
          }
        }
      }
    }

    const values = lines.slice(dataStart).join(' ').trim().split(/\s+/).map(Number);
    if (values.length < width * height * 3) return;

    const imageData = this.ctx.createImageData(width, height);
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const idx = (y * width + x) * 3;
        const didx = (y * width + x) * 4;
        imageData.data[didx] = values[idx] || 0;
        imageData.data[didx + 1] = values[idx + 1] || 0;
        imageData.data[didx + 2] = values[idx + 2] || 0;
        imageData.data[didx + 3] = 255;
      }
    }
    this.ctx.putImageData(imageData, 0, 0);
  }

  setStatus(text, cssClass) {
    this.statusEl.textContent = text;
    this.statusEl.className = cssClass;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.app = new MoonRayApp();
});
