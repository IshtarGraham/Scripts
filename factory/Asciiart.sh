#!/bin/bash
echo "enter the path to the input image:"
read -e  input_image 


jp2a --width=80 "$input_image"
