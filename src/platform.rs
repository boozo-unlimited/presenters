//! Small OS-specific helpers, kept behind `cfg` here per the project layout.

use std::path::Path;

/// Open the given file's containing folder in the OS file manager, revealing the file
/// where supported: Finder on macOS, Explorer on Windows, the default file manager on
/// Linux/BSD (which opens the directory, as there is no portable "reveal").
pub fn reveal_in_file_manager(path: &Path) {
  #[cfg(target_os = "macos")]
  {
    let _ = std::process::Command::new("open").arg("-R").arg(path).spawn();
  }
  #[cfg(target_os = "windows")]
  {
    let _ = std::process::Command::new("explorer").arg(format!("/select,{}", path.display())).spawn();
  }
  #[cfg(all(unix, not(target_os = "macos")))]
  {
    let dir = path.parent().unwrap_or(path);
    let _ = std::process::Command::new("xdg-open").arg(dir).spawn();
  }
}
