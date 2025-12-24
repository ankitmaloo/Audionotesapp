#!/usr/bin/env python3
"""
Quick Swift code validation without full project build.
Validates syntax, runs type checking, and optionally executes code snippets.
"""

import subprocess
import sys
import tempfile
import os
from pathlib import Path
import argparse

def validate_swift_code(code: str, run: bool = False) -> dict:
    """
    Validate Swift code snippet.
    
    Args:
        code: Swift code to validate
        run: If True, attempts to execute the code
    
    Returns:
        dict with 'valid' (bool), 'output' (str), and 'errors' (str)
    """
    result = {
        'valid': False,
        'output': '',
        'errors': ''
    }
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
        f.write(code)
        temp_file = f.name
    
    try:
        # First, check syntax with swiftc
        cmd = ['swiftc', '-typecheck', temp_file]
        proc = subprocess.run(cmd, capture_output=True, text=True)
        
        if proc.returncode != 0:
            result['errors'] = proc.stderr
            return result
        
        result['valid'] = True
        result['output'] = "✓ Syntax and type checking passed"
        
        # If requested, try to execute
        if run:
            exec_cmd = ['swift', temp_file]
            exec_proc = subprocess.run(exec_cmd, capture_output=True, text=True, timeout=5)
            result['output'] += f"\n\n--- Execution Output ---\n{exec_proc.stdout}"
            if exec_proc.stderr:
                result['output'] += f"\n--- Warnings ---\n{exec_proc.stderr}"
        
    except subprocess.TimeoutExpired:
        result['errors'] = "Execution timeout (5s limit)"
    except Exception as e:
        result['errors'] = f"Validation error: {str(e)}"
    finally:
        os.unlink(temp_file)
    
    return result

def validate_swiftui_view(view_code: str) -> dict:
    """
    Validate a SwiftUI View by wrapping it in a minimal app structure.
    
    Args:
        view_code: SwiftUI View code
    
    Returns:
        dict with validation results
    """
    wrapper = f"""
import SwiftUI

{view_code}

// Minimal validation wrapper
struct ValidateApp: App {{
    var body: some Scene {{
        WindowGroup {{
            ContentView()
        }}
    }}
}}
"""
    return validate_swift_code(wrapper, run=False)

def main():
    parser = argparse.ArgumentParser(description='Validate Swift code')
    parser.add_argument('file', nargs='?', help='Swift file to validate')
    parser.add_argument('--run', action='store_true', help='Execute the code')
    parser.add_argument('--view', action='store_true', help='Validate as SwiftUI View')
    parser.add_argument('--code', type=str, help='Validate inline code')
    
    args = parser.parse_args()
    
    if args.code:
        code = args.code
    elif args.file:
        with open(args.file, 'r') as f:
            code = f.read()
    else:
        print("Reading from stdin...")
        code = sys.stdin.read()
    
    if args.view:
        result = validate_swiftui_view(code)
    else:
        result = validate_swift_code(code, run=args.run)
    
    if result['valid']:
        print(f"✅ VALID\n{result['output']}")
        sys.exit(0)
    else:
        print(f"❌ INVALID\n{result['errors']}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
