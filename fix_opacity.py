import os
import re

def fix_with_opacity_in_file(file_path):
    """Fix withOpacity calls in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace .withOpacity(value) with .withValues(alpha: value)
        pattern = r'\.withOpacity\(([^)]+)\)'
        replacement = r'.withValues(alpha: \1)'
        
        new_content = re.sub(pattern, replacement, content)
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def fix_all_dart_files():
    """Fix withOpacity in all Dart files"""
    lib_dir = "lib"
    fixed_files = []
    
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if fix_with_opacity_in_file(file_path):
                    fixed_files.append(file_path)
    
    return fixed_files

if __name__ == "__main__":
    fixed = fix_all_dart_files()
    print(f"Fixed withOpacity in {len(fixed)} files:")
    for file in fixed:
        print(f"  - {file}")
