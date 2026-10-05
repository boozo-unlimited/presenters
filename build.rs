//! Build script: embed the application icon into the Windows executable so Explorer and the
//! taskbar show it. No-op on other platforms.

fn main() {
  #[cfg(windows)]
  {
    let mut res = winresource::WindowsResource::new();
    res.set_icon("img/icon.ico");
    if let Err(e) = res.compile() {
      println!("cargo:warning=failed to embed Windows icon: {e}");
    }
  }
}
