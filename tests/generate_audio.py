# Original cues are generated from sine tones; see assets/audio/README.md.
import math
from pathlib import Path
import struct
import wave

SOUNDS = {'pickup': ([660, 880], 0.13), 'serve': ([520, 660], 0.15), 'sale': ([780, 990], 0.14), 'cash': ([880, 1100, 1320], 0.23), 'upgrade': ([523, 659, 784, 1047], 0.3), 'unlock': ([659, 880, 1175], 0.28), 'hire': ([523, 784, 1047], 0.25), 'menu': ([720], 0.055)}

if __name__ == '__main__':
    folder = Path(__file__).resolve().parents[1] / 'assets' / 'audio'
    folder.mkdir(parents=True, exist_ok=True)
    rate = 22050
    for name, (notes, duration) in SOUNDS.items():
        samples = []
        for index in range(int(rate * duration)):
            t = index / rate
            note = notes[min(int(t / duration * len(notes)), len(notes) - 1)]
            envelope = min(1, t / .008, (duration - t) / .035)
            tone = (math.sin(2 * math.pi * note * t) + .18 * math.sin(4 * math.pi * note * t)) / 1.18
            samples.append(round(32767 * .28 * envelope * tone))
        with wave.open(str(folder / (name + '.wav')), 'wb') as output:
            output.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
            output.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
