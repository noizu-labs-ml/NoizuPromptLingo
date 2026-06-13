#!/bin/bash

# Build and run The Robot Paints
echo "Building The Robot Paints..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🚀 Launching app..."
    swift run &
    echo "App window should open shortly."
else
    echo "❌ Build failed"
    exit 1
fi