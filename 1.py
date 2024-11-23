import os
import subprocess
import time

# Configuration
temp_file = "temp_file.txt"  # Temporary file name
commit_message_add = "Add temp file"  # Commit message for adding
commit_message_remove = "Remove temp file"  # Commit message for deleting
commit_count = 100  # Number of commits to make
repo_path = "./."  # Path to your Git repository

# Function to execute shell commands
def run_command(command, cwd=None):
    try:
        result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}")
        exit(1)

# Main automation script
def automate_commits():
    # Navigate to the repository
    if not os.path.isdir(repo_path):
        print(f"Error: Repository path {repo_path} does not exist.")
        return

    os.chdir(repo_path)

    for i in range(commit_count):
        print(f"Commit cycle {i + 1}/{commit_count}")

        # Add a file
        with open(temp_file, "w") as f:
            f.write("This is a temporary file.\n")
        run_command(["git", "add", temp_file])
        run_command(["git", "commit", "-m", commit_message_add])

        # Delete the file
        os.remove(temp_file)
        run_command(["git", "add", temp_file])
        run_command(["git", "commit", "-m", "commit_message_remove"])

        # Pause between commits (optional)
        time.sleep(1)

    print("Automation complete!")

if __name__ == "__main__":
    automate_commits()


