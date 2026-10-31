#!/bin/sh
# Restores the app icons and gradle-wrapper.jar (stored as base64 because they are binary).
cd "$(dirname "$0")" && base64 -d binaries.tar.gz.b64 | tar xzf - && echo "Binaries restored."
