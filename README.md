# AI-Shell

AI-Shell is a command-line interface powered by AI. It allows you to describe tasks in natural language, and the AI will generate and execute the necessary shell commands and scripts to accomplish them.

## Getting Started

This project is configured to work with the Gemini CLI.

1.  **Shell Environment:** This workspace is optimized for the Fish shell.
2.  **Configuration:** Ensure your environment is set up for Gemini CLI operations. Project-specific configurations and artifacts will be stored within the `.gemini` directory in this workspace.

## Features

*   **Natural Language Commands:** Describe what you want to do in plain English.
*   **Local Execution:** All commands are executed safely within your local environment.
*   **Intelligent Tooling:** The AI can write and execute scripts (like Python) when a simple shell command is not enough.
*   **Persistent Memory:** The shell can remember project-specific configurations and preferences across sessions.

## Example of Usage

Here's an example of what you can do with AI-Shell. The user provided the following prompt:

> Please flatten the files in the folder `~/Documents/Novel/` and its subfolders, such that `~/Documents/Novel/More/Other - Characters.doc.docx` becomes `~/Documents/Novel, More, Other - Characters.docx` (with the ".doc.docx" extension fixed), and similarly for all files. So you can see the file has moved out of the "Novel" folder (or subfolder) and the folder names have been added as a suffixes to the file name, changing the path delimiter to ", ".

The AI-Shell then performed the following steps:

1.  Listed the files in the target directory to understand the structure.
2.  Wrote a Python script to handle the file moving, renaming, and extension fixing logic.
3.  Executed the Python script.
4.  Cleaned up the now-empty directories.
5.  Listed the files in the destination directory to verify the result.

This demonstrates the ability of AI-Shell to understand complex requests, break them down into smaller steps, and use the appropriate tools (shell commands, Python scripts) to get the job done.

### Full Example

Here is the full transcript of the interaction. The first part is the prompt the user wrote, and the subsequent writings are the AI doing the work, and showing it was successful.

> Please flattern the files in the folder `~/Documents/Novel/` and its subfolders, such that `~/Documents/Novel/More/Other - Characters.doc.docx` becomes `~/Documents/Novel, More, Other - Characters.docx` (with the ".doc.docx" extension fixed), and similarly for all files. So you can see the file has moved out of the "Novel" folder (or subfolder) and the folder names have been added as a suffixes to the file name, changing the path delimiter to ", ".

```
  ✓  ReadManyFiles  Attempting to read files from ../../Documents/Novel/**, ../../Documents/Novel/More/Other - Characters.doc.docx → Read 48 file(s)

✦ I will first list the files in the target directory to confirm the structure and then create a script to perform the renaming and flattening as requested.

│ ✓  Shell find "~/Documents/Novel" -type f
│
│ ... first 39 lines hidden (Ctrl+O to show) ...
│ ~/Documents/Novel/Original/Chapter 08 - First Contact.doc.docx
│ ~/Documents/Novel/Original/Species - Bears.doc.docx
│ ~/Documents/Novel/Original/Other - Characters.doc.docx
│ ~/Documents/Novel/Original/Other - Humanity.doc.docx
│ ~/Documents/Novel/More/Converse bites.docx
│ ~/Documents/Novel/More/Alien Speech.doc.docx
│ ~/Documents/Novel/More/Species - Horses.doc.docx
│ ~/Documents/Novel/More/Other - Characters.doc.docx
│ ~/Documents/Novel - Bullet-pointed mind map.docx

✦ I will now create and run a Python script to flatten the files, rename them by replacing path delimiters with commas, and fix the ".doc.docx" extensions.

  ✓  WriteFile  flatten_novel.py → Accepted (+30, -0)

       1 import os
       2 import shutil
       3
       4 base_dir = "~/Documents"
       5 source_dir = os.path.join(base_dir, "Novel")
       6
       7 # Walk through the Novel directory
       8 for root, dirs, files in os.walk(source_dir):
       9     for file in files:
      10         # Full path to the original file
      11         old_path = os.path.join(root, file)
      12
      13         # Get path relative to the base_dir (Documents)
      14         # This will include "Novel/..."
      15         rel_path = os.path.relpath(old_path, base_dir)
      16
      17         # Replace path separators with ", "
      18         new_name = rel_path.replace(os.sep, ", ")
      19
      20         # Fix the extension if it's .doc.docx
      21         if new_name.endswith(".doc.docx"):
      22             new_name = new_name[:-9] + ".docx"
      23
      24         # Target path is in the base_dir
      25         new_path = os.path.join(base_dir, new_name)
      26
      27         print("")
      28         print(f"Moving: {old_path}")
      29         print(f"-> {new_path}")
      30         shutil.move(old_path, new_path)
      31
      32 print("Flattening complete.")

✦ I will now execute the script to move and rename the files.

│ ✓  Shell python3 ~/.gemini/tmp/ai-shell/flatten_novel.py
│
│ ... first 58 lines hidden (Ctrl+O to show) ...
│
│ Moving: ~/Documents/Novel/Original/Species - Shadow.doc.docx
│ -> ~/Documents/Novel, Original, Species - Shadow.docx
│
│ Moving: ~/Documents/Novel/Original/Chapter 08 - First Contact.doc.docx
│ -> ~/Documents/Novel, Original, Chapter 08 - First Contact.docx
│
│ Moving: ~/Documents/Novel/Original/Species - Bears.doc.docx
│ -> ~/Documents/Novel, Original, Species - Bears.docx
│
│ Moving: ~/Documents/Novel/Original/Other - Characters.doc.docx
│ -> ~/Documents/Novel, Original, Other - Characters.docx
│
│ Moving: ~/Documents/Novel/Original/Other - Humanity.doc.docx
│ -> ~/Documents/Novel, Original, Other - Humanity.docx
│
│ Moving: ~/Documents/Novel/More/Converse bites.docx
│ -> ~/Documents/Novel, More, Converse bites.docx

✦ I will check for any remaining files and then remove the now-empty directories in the Novel folder.

│ ✓  Shell find "~/Documents/Novel" -type f && find "~/Documents/Novel" -type d -empty -delete

✦ I will now list the files in the base directory to verify the results of the flattening and renaming.

│ ✓  Shell ls "~/Documents/"
│
│ ... first 16 lines hidden (Ctrl+O to show) ...
│ 'Novel, Original, Chapter 07 - Alien Technology.docx'
│ 'Novel, Original, Chapter 08 - First Contact.docx'
│ 'Novel, Original, Chapter 09 - Total Annihilation.docx'
│ 'Novel, Original, Chapter 10 - The Forge.docx'
│ 'Novel, Original, Insertix 01 - Rat Scourge.docx'
│ 'Novel, Original, Insertix 02 - Alien Children.docx'
│ 'Novel, Original, Back Cover.docx'
│ 'Novel, Original, Ideas - Concepts.docx'
│ 'Novel, Original, Ideas - Scenes.docx'
│ 'Novel, Thoughts, 1st Thoughts.docx'
│ 'Novel, Thoughts, 2nd Thoughts.docx'
│ 'Novel, Thoughts, 3rd Thoughts.docx'
│ 'Novel, Thoughts, 4th Thoughts.docx'
│ 'Novel, Thoughts, Additions 1.docx'
│ 'Novel, Thoughts, Additions 2.docx'
│ 'Novel, Thoughts, Additions 3.docx'
│ 'Novel, Thoughts, Additions 4.docx'
│ 'Novel, To do.docx'

✦ I have successfully flattened the files, renamed them by converting path delimiters to commas, and corrected the ".doc.docx" extensions.

│ ✓  Shell rm ~/.gemini/tmp/ai-shell/flatten_novel.py

✦ The files in ~/Documents/Novel and its subfolders have been flattened into ~/Documents/.

  The folder structure was preserved in the filenames by replacing path delimiters with , , and all .doc.docx extensions were corrected to .docx. The original Novel directory and its
  subdirectories have been emptied and removed.
```
