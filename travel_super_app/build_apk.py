"""
Build APK script - workaround for terminal issues
"""
import subprocess
import os
import sys
from pathlib import Path

project_dir = Path(r"c:\GitHub\Travel_App\travel_super_app")
os.chdir(project_dir)

print(f"📂 Working directory: {os.getcwd()}")
print(f"📄 pubspec.yaml exists: {(project_dir / 'pubspec.yaml').exists()}")
print("\n🔨 Building APK (this takes 3-5 minutes)...")
print("=" * 70)

try:
    # Find flutter command
    flutter_cmd = r"C:\Flutter\flutter\bin\flutter.bat"
    if not Path(flutter_cmd).exists():
        # Try PATH
        flutter_cmd = "flutter"
    
    print(f"Using Flutter: {flutter_cmd}")
    
    # Run flutter build apk
    process = subprocess.Popen(
        [flutter_cmd, "build", "apk", "--release"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        universal_newlines=True
    )
    
    # Print output in real-time
    for line in process.stdout:
        print(line, end='')
    
    process.wait()
    
    if process.returncode == 0:
        apk_path = project_dir / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
        if apk_path.exists():
            size_mb = apk_path.stat().st_size / (1024 * 1024)
            print(f"\n✅ APK built successfully!")
            print(f"📦 Location: {apk_path}")
            print(f"📏 Size: {size_mb:.2f} MB")
            print(f"\n🚀 Install to phone:")
            print(f"   flutter install")
            print(f"   OR")
            print(f"   adb install {apk_path}")
        else:
            print(f"\n❌ APK not found at: {apk_path}")
            sys.exit(1)
    else:
        print(f"\n❌ Build failed with exit code: {process.returncode}")
        sys.exit(1)
        
except FileNotFoundError:
    print("\n❌ Flutter not found. Make sure Flutter is in PATH.")
    sys.exit(1)
except KeyboardInterrupt:
    print("\n⚠️  Build interrupted by user")
    process.terminate()
    sys.exit(1)
except Exception as e:
    print(f"\n❌ Error: {e}")
    sys.exit(1)
