#!/bin/bash

# Record audio for a short duration (10 seconds in this example)
duration=10
output_file="recorded_audio.wav"

echo "Recording audio for $duration seconds..."
arecord -d "$duration" -f cd -t wav -r 44100 -D default "$output_file"

echo "Audio recording complete."

# Analyze the frequency spectrum using sox
sox "$output_file" -n spectrogram -o spectrogram.png

echo "Frequency analysis complete. Opening the spectrogram..."

# Open the spectrogram using the default image viewer
xdg-open spectrogram.png

