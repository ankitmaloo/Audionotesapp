#!/usr/bin/env python3
"""
Scaffold Swift projects with proper structure and configuration.
Supports iOS, macOS, and multiplatform apps with SwiftUI.
"""

import os
import sys
import argparse
from pathlib import Path
import subprocess

TEMPLATES = {
    'ios': {
        'name': 'iOS App (SwiftUI)',
        'platforms': 'iOS',
        'deployment_target': '17.0'
    },
    'macos': {
        'name': 'macOS App (SwiftUI)',
        'platforms': 'macOS',
        'deployment_target': '14.0'
    },
    'multiplatform': {
        'name': 'Multiplatform App',
        'platforms': 'iOS, macOS',
        'deployment_target': 'iOS 17.0, macOS 14.0'
    }
}

def create_xcode_project(name: str, platform: str, path: str):
    """Create an Xcode project using xcodebuild or create SPM package."""
    project_path = Path(path) / name
    
    # For simple projects, use Swift Package Manager
    cmd = [
        'swift', 'package', 'init',
        '--type', 'executable',
        '--name', name
    ]
    
    project_path.mkdir(parents=True, exist_ok=True)
    subprocess.run(cmd, cwd=project_path, check=True)
    
    print(f"✅ Created Swift package at {project_path}")
    return project_path

def create_swiftui_app_structure(name: str, platform: str, path: str):
    """Create a SwiftUI app structure with Package.swift."""
    project_path = Path(path) / name
    project_path.mkdir(parents=True, exist_ok=True)
    
    sources_path = project_path / 'Sources'
    sources_path.mkdir(exist_ok=True)
    
    # Create Package.swift
    template = TEMPLATES.get(platform, TEMPLATES['ios'])
    package_swift = f"""// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "{name}",
    platforms: [
        {'.iOS(.v17)' if 'iOS' in template['platforms'] else ''}
        {'.macOS(.v14)' if 'macOS' in template['platforms'] else ''}
    ],
    products: [
        .executable(name: "{name}", targets: ["{name}"])
    ],
    targets: [
        .executableTarget(name: "{name}")
    ]
)
"""
    
    with open(project_path / 'Package.swift', 'w') as f:
        f.write(package_swift)
    
    # Create main app file
    app_path = sources_path / name
    app_path.mkdir(exist_ok=True)
    
    main_swift = f"""import SwiftUI

@main
struct {name}App: App {{
    var body: some Scene {{
        WindowGroup {{
            ContentView()
        }}
    }}
}}

struct ContentView: View {{
    var body: some View {{
        VStack {{
            Text("Welcome to {name}")
                .font(.largeTitle)
                .padding()
        }}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }}
}}

#Preview {{
    ContentView()
}}
"""
    
    with open(app_path / 'main.swift', 'w') as f:
        f.write(main_swift)
    
    # Create .gitignore
    gitignore = """.DS_Store
/.build
/Packages
xcuserdata/
DerivedData/
.swiftpm/
"""
    with open(project_path / '.gitignore', 'w') as f:
        f.write(gitignore)
    
    print(f"✅ Created SwiftUI app at {project_path}")
    print(f"   Platform: {template['platforms']}")
    print(f"\nTo build and run:")
    print(f"   cd {name}")
    print(f"   swift build")
    print(f"   swift run")
    
    return project_path

def main():
    parser = argparse.ArgumentParser(description='Scaffold Swift app project')
    parser.add_argument('name', help='Project name')
    parser.add_argument('--platform', choices=['ios', 'macos', 'multiplatform'], 
                       default='macos', help='Target platform')
    parser.add_argument('--path', default='.', help='Output directory')
    
    args = parser.parse_args()
    
    create_swiftui_app_structure(args.name, args.platform, args.path)

if __name__ == '__main__':
    main()
