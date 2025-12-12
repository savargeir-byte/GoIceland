"""
Deploy Firebase Functions Script
Workaround for PowerShell terminal issues
"""
import subprocess
import os
import sys

# Change to the correct directory
project_dir = r"c:\GitHub\Travel_App\travel_super_app"
os.chdir(project_dir)

print(f"📂 Current directory: {os.getcwd()}")
print(f"📄 firebase.json exists: {os.path.exists('firebase.json')}")

# Run firebase deploy
print("\n🚀 Deploying Cloud Functions...")
print("=" * 60)

# Try to find firebase command
firebase_cmd = "firebase"
try:
    # Check if firebase is in PATH
    subprocess.run([firebase_cmd, "--version"], capture_output=True, check=True)
except (FileNotFoundError, subprocess.CalledProcessError):
    # Try npm global path
    firebase_cmd = r"C:\Users\Computer\AppData\Roaming\npm\firebase.cmd"
    if not os.path.exists(firebase_cmd):
        print("❌ Firebase CLI not found. Install with: npm install -g firebase-tools")
        sys.exit(1)

print(f"Using firebase command: {firebase_cmd}")

try:
    result = subprocess.run(
        [firebase_cmd, "deploy", "--only", "functions", "--project", "go-iceland"],
        cwd=project_dir,
        capture_output=True,
        text=True,
        timeout=600  # 10 minute timeout
    )
    
    print(result.stdout)
    if result.stderr:
        print("STDERR:", result.stderr)
    
    if result.returncode == 0:
        print("\n✅ Deployment successful!")
    else:
        print(f"\n❌ Deployment failed with exit code: {result.returncode}")
        sys.exit(1)
        
except subprocess.TimeoutExpired:
    print("\n⏰ Deployment timed out (> 10 minutes)")
    sys.exit(1)
except Exception as e:
    print(f"\n❌ Error: {e}")
    sys.exit(1)
