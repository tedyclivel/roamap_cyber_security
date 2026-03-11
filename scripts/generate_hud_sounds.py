import numpy as np
from scipy.io import wavfile
import os

def generate_beep(filename, freq=1000, duration=0.1, volume=0.3):
    sample_rate = 44100
    t = np.linspace(0, duration, int(sample_rate * duration))
    # Sine wave
    data = np.sin(2 * np.pi * freq * t) * volume
    # Fade in/out to avoid clicks
    fade = int(sample_rate * 0.01)
    if len(data) > 2 * fade:
        data[:fade] *= np.linspace(0, 1, fade)
        data[-fade:] *= np.linspace(1, 0, fade)
    
    wavfile.write(filename, sample_rate, (data * 32767).astype(np.int16))

def generate_glitch(filename, duration=0.2, volume=0.2):
    sample_rate = 44100
    # Noise with periodic chirps
    data = np.random.uniform(-1, 1, int(sample_rate * duration)) * volume
    t = np.linspace(0, duration, len(data))
    chirp = np.sin(2 * np.pi * 500 * t * t) * volume
    data = (data + chirp) * 0.5
    
    wavfile.write(filename, sample_rate, (data * 32767).astype(np.int16))

def main():
    out_dir = r'c:\Users\eganh\Documents\LABHACKING\roamap\assets\sounds'
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
        
    print(">>> Generating HUD Audio Assets...")
    generate_beep(os.path.join(out_dir, 'ui_beep.wav'), freq=880, duration=0.08)
    generate_beep(os.path.join(out_dir, 'ui_success.wav'), freq=1320, duration=0.15, volume=0.4)
    generate_glitch(os.path.join(out_dir, 'ui_glitch.wav'))
    print(f">>> Assets generated in {out_dir}")

if __name__ == "__main__":
    main()
