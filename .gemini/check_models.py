import os
import subprocess
import json
import sys
import re
import glob

SETTINGS_FILE = os.path.join(os.path.dirname(__file__), "settings.json")

def read_current_model():
    """Read the current model from settings.json"""
    try:
        with open(SETTINGS_FILE, 'r') as f:
            settings = json.load(f)
            model = settings.get("model", {}).get("name", "gemini-1.0")
            return model
    except Exception as e:
        return "gemini-1.0"

def extract_version(model_name):
    """Extract version number from model name like 'gemini-2.5-flash-lite' -> (2, 5)"""
    try:
        parts = model_name.split('-')
        for part in parts:
            if '.' in part and all(p.isdigit() for p in part.split('.')):
                version_parts = part.split('.')
                return tuple(int(p) for p in version_parts)
    except:
        pass
    return (0, 0)

def get_model_family(model_name):
    """Extract model family (everything after version, e.g., 'flash-lite' from 'gemini-2.5-flash-lite')"""
    try:
        parts = model_name.split('-')
        for i, part in enumerate(parts):
            if '.' in part and all(p.isdigit() for p in part.split('.')):
                if i + 1 < len(parts):
                    # Remove -preview suffix for family matching
                    family = '-'.join(parts[i+1:])
                    if family.endswith('-preview'):
                        family = family[:-8]
                    return family
    except:
        pass
    return None

def find_gemini_cli_bundle():
    """Find the Gemini CLI bundle directory"""
    possible_paths = [
        os.path.expanduser("~/.local/lib/node_modules/@google/gemini-cli/bundle"),
        "/usr/local/lib/node_modules/@google/gemini-cli/bundle",
        "/usr/lib/node_modules/@google/gemini-cli/bundle",
    ]

    # Also try to find via `which gemini`
    try:
        result = subprocess.run(["which", "gemini"], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            gemini_path = result.stdout.strip()
            # Follow symlink to find bundle
            if os.path.islink(gemini_path):
                real_path = os.path.realpath(gemini_path)
                bundle_path = os.path.dirname(real_path)
                possible_paths.insert(0, bundle_path)
    except:
        pass

    for path in possible_paths:
        if os.path.exists(path):
            return path

    return None

def get_available_models_from_bundle():
    """Parse Gemini CLI bundle to get available models"""
    bundle_path = find_gemini_cli_bundle()
    if not bundle_path:
        return []

    # Find JS chunks that contain model definitions
    models = set()
    js_files = glob.glob(os.path.join(bundle_path, "chunk-*.js"))

    for js_file in js_files:
        try:
            with open(js_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            # Look for model definitions with isVisible: true
            # Pattern: "gemini-X.X-..." followed by isVisible: true within ~500 chars
            pattern = r'"(gemini-[\d.]+-[^"]+)"[^}]{0,500}isVisible:\s*true'
            matches = re.findall(pattern, content)

            for match in matches:
                if not match.endswith('-customtools'):  # Skip internal variants
                    models.add(match)

        except Exception as e:
            pass

    return sorted(models)

def check(verbose=False):
    """Check if a newer model is available.

    Args:
        verbose: If True, print results to stdout. If False, only notify on new findings.
    """
    if os.environ.get("SKIP_GEMINI_HOOKS") == "1":
        return

    current_model = read_current_model()
    current_version = extract_version(current_model)
    current_family = get_model_family(current_model)

    # Get available models from Gemini CLI bundle (fast, local operation)
    available_models = get_available_models_from_bundle()

    if not available_models:
        if verbose:
            print("⚠️  Could not determine available models. Is Gemini CLI installed?")
        return

    # Find the latest model in the same family
    latest_model = current_model
    latest_version = current_version

    for model in available_models:
        model_family = get_model_family(model)
        model_version = extract_version(model)

        # Only compare models in the same family
        if model_family == current_family and model_version > latest_version:
            latest_model = model
            latest_version = model_version

    # Report results
    if latest_model != current_model:
        if verbose:
            print(f"💡 A newer model ({latest_model}) is available. Update your settings.json to switch.")
        else:
            sys.stderr.write(f"\n💡 A newer model ({latest_model}) is available. Run /model-check for details.\n")
    else:
        if verbose:
            print(f"✅ You are using the latest available model ({current_model}).")
            print(f"\nAvailable models in your session:")
            for m in available_models:
                marker = " (current)" if m == current_model else ""
                print(f"  - {m}{marker}")

if __name__ == "__main__":
    # If run directly (e.g., from /model-check command), show output
    # If run from hooks, verbose is False by default
    verbose = "--verbose" in sys.argv or len(sys.argv) == 1
    check(verbose=verbose)
