use std::path::PathBuf;
use std::process::{Command, Child, Stdio};
use std::time::Instant;

/// Check whether SoX is available on PATH.
pub fn check_sox_installed() -> bool {
    Command::new("which")
        .arg("sox")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Manages a SoX recording process that writes to a temporary WAV file.
/// Used by the tabbing-plan TUI when audio recording is wired in.
#[allow(dead_code)]
pub struct Recorder {
    child: Option<Child>,
    start_time: Option<Instant>,
    tmp_file: Option<PathBuf>,
}

#[allow(dead_code)]
impl Recorder {
    pub fn new() -> Self {
        Self {
            child: None,
            start_time: None,
            tmp_file: None,
        }
    }

    /// Spawn `rec` to capture 16 kHz mono 16-bit WAV into a temp file.
    pub fn start(&mut self) -> Result<(), String> {
        if self.child.is_some() {
            return Err("Already recording".into());
        }

        let tmp_path = PathBuf::from(format!(
            "/tmp/tabbing-plan-recording-{}.wav",
            std::process::id()
        ));

        let child = Command::new("rec")
            .args([
                "-t", "wav",
                "-r", "16000",
                "-c", "1",
                "-b", "16",
            ])
            .arg(tmp_path.as_os_str())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .map_err(|e| format!("Failed to spawn rec: {}", e))?;

        self.child = Some(child);
        self.start_time = Some(Instant::now());
        self.tmp_file = Some(tmp_path);

        Ok(())
    }

    /// Stop the recording, read the WAV data, clean up the temp file.
    pub fn stop(&mut self) -> Result<Vec<u8>, String> {
        let mut child = self.child.take().ok_or("Not recording")?;

        // Send SIGTERM so SoX finalises the WAV header.
        // Use the `kill` command to avoid a libc dependency.
        #[cfg(unix)]
        {
            let pid = child.id().to_string();
            let _ = Command::new("kill")
                .args(["-s", "TERM", &pid])
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .status();
        }
        #[cfg(not(unix))]
        {
            let _ = child.kill();
        }

        child.wait().map_err(|e| format!("Wait failed: {}", e))?;
        self.start_time = None;

        let tmp_path = self.tmp_file.take().ok_or("No temp file path")?;

        let data = std::fs::read(&tmp_path)
            .map_err(|e| format!("Failed to read {}: {}", tmp_path.display(), e))?;

        let _ = std::fs::remove_file(&tmp_path);

        Ok(data)
    }

    /// Elapsed whole seconds since recording started.
    pub fn duration_secs(&self) -> u64 {
        self.start_time
            .map(|t| t.elapsed().as_secs())
            .unwrap_or(0)
    }

    pub fn is_recording(&self) -> bool {
        self.child.is_some()
    }
}

impl Drop for Recorder {
    fn drop(&mut self) {
        if let Some(mut child) = self.child.take() {
            let _ = child.kill();
            let _ = child.wait();
        }
        if let Some(ref path) = self.tmp_file.take() {
            let _ = std::fs::remove_file(path);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compute_amplitude_silence() {
        let silence = vec![0u8; 100];
        let amp = compute_amplitude(&silence, 0, 100);
        assert_eq!(amp, 0.0);
    }

    #[test]
    fn test_compute_amplitude_max() {
        let mut data = Vec::new();
        for _ in 0..50 {
            data.extend_from_slice(&i16::MAX.to_le_bytes());
        }
        let amp = compute_amplitude(&data, 0, data.len());
        assert!(amp > 0.9);
        assert!(amp <= 1.0);
    }

    #[test]
    fn test_compute_amplitude_empty() {
        let amp = compute_amplitude(&[], 0, 0);
        assert_eq!(amp, 0.0);
    }

    #[test]
    fn test_compute_amplitude_single_byte() {
        let amp = compute_amplitude(&[0], 0, 1);
        assert_eq!(amp, 0.0);
    }

    #[test]
    fn test_compute_amplitude_offset() {
        let mut data = vec![0u8; 20];
        data.extend_from_slice(&i16::MAX.to_le_bytes());
        data.extend_from_slice(&i16::MAX.to_le_bytes());
        let amp_start = compute_amplitude(&data, 0, 20);
        let amp_end = compute_amplitude(&data, 20, 4);
        assert_eq!(amp_start, 0.0);
        assert!(amp_end > 0.9);
    }

    #[test]
    fn test_recorder_new() {
        let r = Recorder::new();
        assert!(!r.is_recording());
        assert_eq!(r.duration_secs(), 0);
    }
}

/// Compute the RMS amplitude of 16-bit LE PCM samples in `wav_data`
/// starting at `offset` for `window` bytes.  Returns a value in 0.0..=1.0.
#[allow(dead_code)]
pub fn compute_amplitude(wav_data: &[u8], offset: usize, window: usize) -> f32 {
    let end = (offset + window).min(wav_data.len());
    if end <= offset || (end - offset) < 2 {
        return 0.0;
    }

    let slice = &wav_data[offset..end];
    let sample_count = slice.len() / 2;
    if sample_count == 0 {
        return 0.0;
    }

    let mut sum_squares: f64 = 0.0;
    for i in (0..slice.len() - 1).step_by(2) {
        let sample = i16::from_le_bytes([slice[i], slice[i + 1]]) as f64;
        sum_squares += sample * sample;
    }

    let rms = (sum_squares / sample_count as f64).sqrt();
    (rms / 32768.0).min(1.0) as f32
}
