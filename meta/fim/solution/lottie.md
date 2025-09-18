# Lottie Animation Framework

Render After Effects animations natively on web and mobile.

## Core Features
- After Effects export support
- JSON-based animations
- Bodymovin integration
- Interactive controls

## Basic Setup
```javascript
// CDN: https://cdnjs.cloudflare.com/ajax/libs/lottie-web/5.12.2/lottie.min.js
import lottie from 'lottie-web';
```

## Animation Examples
```javascript
// Basic animation
const animation = lottie.loadAnimation({
  container: document.getElementById('lottie-container'),
  renderer: 'svg',
  loop: true,
  autoplay: true,
  path: 'data.json' // Exported from After Effects
});

// With controls
const animationWithControls = lottie.loadAnimation({
  container: document.querySelector('.animation'),
  renderer: 'canvas',
  loop: false,
  autoplay: false,
  animationData: animationData // JSON object
});

// Play control
animationWithControls.play();
animationWithControls.pause();
animationWithControls.stop();
animationWithControls.setSpeed(2);
animationWithControls.setDirection(-1);

// Segment playback
animation.playSegments([0, 120], true);

// Interactive animation
animation.addEventListener('enterFrame', (e) => {
  console.log('Current frame:', e.currentTime);
});

// Scroll-based animation
window.addEventListener('scroll', () => {
  const scrollPercent = window.scrollY / (document.body.scrollHeight - window.innerHeight);
  const frame = Math.floor(scrollPercent * animation.totalFrames);
  animation.goToAndStop(frame, true);
});
```

## NPL-FIM Integration
```javascript
// Lottie controller pattern
const lottieController = {
  load: (container, path) => lottie.loadAnimation({
    container,
    renderer: 'svg',
    loop: true,
    autoplay: true,
    path
  }),

  interactive: (container, data, trigger) => {
    const anim = lottie.loadAnimation({ container, animationData: data, autoplay: false });
    trigger.addEventListener('mouseenter', () => anim.play());
    trigger.addEventListener('mouseleave', () => anim.pause());
    return anim;
  }
};
```

## Key Methods
- play(): Start animation
- pause(): Pause animation
- stop(): Stop and reset
- setSpeed(speed): Adjust playback speed
- goToAndStop(frame, isFrame): Jump to frame