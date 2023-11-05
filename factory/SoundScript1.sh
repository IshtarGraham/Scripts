#!/bin/bash

# Adjust the audio parameters based on your environment
AUDIO_DEVICE="default"
THRESHOLD_DB=-5.5  #Adjust this threshold based on observed dB values

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
    # Compare mean volume in dB with the threshold
    if (( $(echo "$MEAN_VOLUME_DB > $THRESHOLD_DB" | bc -l) )); then
      echo "Clap detected"
      ((claps++))
    else
      echo "No clap detected"
    fi
  else
    echo "Error: Invalid or empty mean volume value in dB"
  fi

  # Sleep for 2 seconds before the next iteration


  # Print the number of claps detected in the 2-second interval
  echo "Claps detected in last 2 seconds: $claps"

  # Check for user input to exit the loop
  if read -t 0.1 -N 1 && [[ $REPLY == q ]]; then
    break
  fi

  # Reset the clap counter for the next interval
  claps=0
done

