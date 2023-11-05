#!/bin/bash
echo "enter an URL to shlurp:"
read url

wget --recursive --no-clobber --page-requisites --convert-links --html-extension --no-parent --wait=3 "$url"

