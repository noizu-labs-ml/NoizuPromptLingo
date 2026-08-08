# ml5.js Machine Learning for Creatives

Friendly machine learning for web-based creative coding.

## Core Features
- Pre-trained models
- Image classification
- Pose detection
- Style transfer

## Basic Setup
```javascript
// CDN: https://unpkg.com/ml5@latest/dist/ml5.min.js
// Requires p5.js: https://cdn.jsdelivr.net/npm/p5@1.7.0/lib/p5.min.js
```

## ML Model Examples
```javascript
// Image classifier
let classifier;
let img;

function preload() {
  classifier = ml5.imageClassifier('MobileNet');
  img = loadImage('image.jpg');
}

function setup() {
  createCanvas(400, 400);
  classifier.classify(img, gotResult);
}

function gotResult(error, results) {
  if (error) {
    console.error(error);
  } else {
    console.log(results);
    // results[0].label, results[0].confidence
  }
}

// PoseNet for pose detection
let video;
let poseNet;
let poses = [];

function setup() {
  createCanvas(640, 480);
  video = createCapture(VIDEO);
  video.size(640, 480);
  video.hide();

  poseNet = ml5.poseNet(video, modelReady);
  poseNet.on('pose', (results) => {
    poses = results;
  });
}

function modelReady() {
  console.log('Model Loaded');
}

function draw() {
  image(video, 0, 0);
  drawKeypoints();
  drawSkeleton();
}

function drawKeypoints() {
  for (let pose of poses) {
    for (let keypoint of pose.pose.keypoints) {
      if (keypoint.score > 0.2) {
        fill(255, 0, 0);
        noStroke();
        ellipse(keypoint.position.x, keypoint.position.y, 10, 10);
      }
    }
  }
}

// Style Transfer
let styleTransfer;
let img;
let result;

function preload() {
  img = loadImage('input.jpg');
}

function setup() {
  createCanvas(500, 500);
  styleTransfer = ml5.styleTransfer('udnie', modelLoaded);
}

function modelLoaded() {
  styleTransfer.transfer(img, (err, res) => {
    result = res;
  });
}

function draw() {
  if (result) {
    image(result, 0, 0, 500, 500);
  }
}

// HandPose detection
let handpose;
let predictions = [];

function setup() {
  createCanvas(640, 480);
  video = createCapture(VIDEO);
  video.hide();

  handpose = ml5.handpose(video, modelReady);
  handpose.on('predict', results => {
    predictions = results;
  });
}

function draw() {
  image(video, 0, 0);

  for (let hand of predictions) {
    for (let landmark of hand.landmarks) {
      fill(0, 255, 0);
      noStroke();
      ellipse(landmark[0], landmark[1], 10, 10);
    }
  }
}
```

## NPL-FIM Integration
```javascript
// Creative ML patterns
const ml5Patterns = {
  interactiveClassifier: (video) => {
    const classifier = ml5.imageClassifier('MobileNet', video);

    setInterval(() => {
      classifier.classify((err, results) => {
        if (!err && results[0].confidence > 0.7) {
          triggerCreativeEffect(results[0].label);
        }
      });
    }, 1000);
  },

  poseArt: (poses) => {
    poses.forEach(pose => {
      const nose = pose.pose.nose;
      const leftWrist = pose.pose.leftWrist;

      if (nose.confidence > 0.5 && leftWrist.confidence > 0.5) {
        stroke(random(255), random(255), random(255));
        line(nose.x, nose.y, leftWrist.x, leftWrist.y);
      }
    });
  }
};
```

## Available Models
- imageClassifier: Object detection
- poseNet: Body pose tracking
- handpose: Hand tracking
- facemesh: Face landmarks
- styleTransfer: Artistic styles
- soundClassifier: Audio classification