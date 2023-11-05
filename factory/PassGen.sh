#!/bin/bash
echo "enter your wannabe password lenght:"
read length

password=$(openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-$length)

echo "Generated Password: $password"
