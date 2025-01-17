import os
import sys

def create_init_files(base_dir, exclude_dirs=None):
    if exclude_dirs is None:
        exclude_dirs = []

    for root, _, files in os.walk(base_dir):
        # Skip excluded directories or the root folder
        if root == base_dir or any(excluded in root for excluded in exclude_dirs):
            continue

        # Check if there are any .py files in the folder
        if any(file.endswith('.py') for file in files):
            init_file = os.path.join(root, '__init__.py')
            if not os.path.exists(init_file):
                with open(init_file, 'w', encoding='utf-8') as f:
                    f.write("# __init__.py\n")
                print(f"Created: {init_file}")
            else:
                print(f"Already exists: {init_file}")

if __name__ == "__main__":
    # Use project root passed as an argument or default to current working directory
    project_root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    print(f"Using project root: {project_root}")  # Debugging output
    excluded = ["venv", ".git"]  # Customize this list to exclude specific directories
    create_init_files(project_root, exclude_dirs=excluded)
