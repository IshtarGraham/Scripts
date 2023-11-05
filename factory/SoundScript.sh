#!/bin/bash 

# Adjust the audio parameters based on your environment
AUDIO_DEVICE="default"

# Set threshold based on observed dB values during claps
THRESHOLD_DB_CLAP=-5.5

trap 'break' INT  # Set a trap to break out of the loop when Ctrl+C is pressed

while true; do
  # Record audio for 2 seconds and save to WAV file
  arecord -d 2 -D $AUDIO_DEVICE -f cd -t wav -r 44100 -N - > recorded_audio.wav

  # Process the recorded audio and print mean volume in dB
  MEAN_VOLUME_DB=$(ffmpeg -i recorded_audio.wav -af "volumedetect" -vn -sn -dn -f null /dev/null 2>&1 | \
    awk '/mean_volume/ {print $(NF-1)}' | tr -d 'dB')

  echo "Mean volume (dB): $MEAN_VOLUME_DB"

  # Check if mean volume in dB is not empty and is numeric
  if [ -n "$MEAN_VOLUME_DB" ] && [[ "$MEAN_VOLUME_DB" =~ ^[0-9.-]+$ ]]; then
    # Compare mean volume in dB with the threshold for clap detection
    if (( $(echo "$MEAN_VOLUME_DB > $THRESHOLD_DB_CLAP" | bc -l) )); then
      # Use sox to analyze the frequency content
      CLAP_FREQUENCY_RANGE=$(sox recorded_audio.wav -n stat 2>&1 | grep "Overall" | awk '{print $6}')
      # Adjust these frequency ranges based on your observations
      if (( $(echo "$CLAP_FREQUENCY_RANGE > 400" | bc -l) )); then
        echo "Clap detected"
      else
        echo "Different sound detected"
      fi
    else
      echo "No clap detected"
    fi
  else
    echo "Error: Invalid or empty mean volume value in dB"
  fi

  # Sleep for 2 seconds before the next iteration
  sleep 2

  # Check for user input to exit the loop
  if read -t 0.1 -N 1 && [[ $REPLY == q ]]; then
    break
  fi
done
