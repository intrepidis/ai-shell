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

## Example of Usage 1
Here's an example of what you can do with AI-Shell. The user provided the following prompt:

> Please flatten the files in the folder `~/Documents/Novel/` and its subfolders, such that `~/Documents/Novel/More/Other - Characters.doc.docx` becomes `~/Documents/Novel, More, Other - Characters.docx` (with the ".doc.docx" extension fixed), and similarly for all files. So you can see the file has moved out of the "Novel" folder (or subfolder) and the folder names have been added as a suffixes to the file name, changing the path delimiter to ", ".

The AI-Shell then performed the following steps:
1.  Listed the files in the target directory to understand the structure.
2.  Wrote a Python script to handle the file moving, renaming, and extension fixing logic.
3.  Executed the Python script.
4.  Cleaned up the now-empty directories.
5.  Listed the files in the destination directory to verify the result.

This demonstrates the ability of AI-Shell to understand complex requests, break them down into smaller steps, and use the appropriate tools (shell commands, Python scripts) to get the job done.

### Full Example 1
Here is the full transcript of the interaction. The first part is the prompt the user wrote, and the subsequent writings are the AI doing the work, and showing it was successful.

> Please flattern the files in the folder `~/Documents/Novel/` and its subfolders, such that `~/Documents/Novel/More/Other - Characters.doc.docx` becomes `~/Documents/Novel, More, Other - Characters.docx` (with the ".doc.docx" extension fixed), and similarly for all files. So you can see the file has moved out of the "Novel" folder (or subfolder) and the folder names have been added as a suffixes to the file name, changing the path delimiter to ", ".

  ✓  ReadManyFiles  Attempting to read files from ../../Documents/Novel/**, ../../Documents/Novel/More/Other - Characters.doc.docx → Read 48 file(s)

✦ I will first list the files in the target directory to confirm the structure and then create a script to perform the renaming and flattening as requested.

  ✓  Shell find "~/Documents/Novel" -type f

```sh
... first 39 lines hidden (Ctrl+O to show) ...
~/Documents/Novel/Original/Chapter 08 - First Contact.doc.docx
~/Documents/Novel/Original/Species - Bears.doc.docx
~/Documents/Novel/Original/Other - Characters.doc.docx
~/Documents/Novel/Original/Other - Humanity.doc.docx
~/Documents/Novel/More/Converse bites.docx
~/Documents/Novel/More/Alien Speech.doc.docx
~/Documents/Novel/More/Species - Horses.doc.docx
~/Documents/Novel/More/Other - Characters.doc.docx
~/Documents/Novel - Bullet-pointed mind map.docx
```

✦ I will now create and run a Python script to flatten the files, rename them by replacing path delimiters with commas, and fix the ".doc.docx" extensions.

  ✓  WriteFile  flatten_novel.py → Accepted (+30, -0)

```python
import os
import shutil

base_dir = "~/Documents"
source_dir = os.path.join(base_dir, "Novel")

# Walk through the Novel directory
for root, dirs, files in os.walk(source_dir):
  for file in files:
    # Full path to the original file
    old_path = os.path.join(root, file)

    # Get path relative to the base_dir (Documents)
    # This will include "Novel/..."
    rel_path = os.path.relpath(old_path, base_dir)

    # Replace path separators with ", "
    new_name = rel_path.replace(os.sep, ", ")

    # Fix the extension if it's .doc.docx
    if new_name.endswith(".doc.docx"):
        new_name = new_name[:-9] + ".docx"

    # Target path is in the base_dir
    new_path = os.path.join(base_dir, new_name)

    print("")
    print(f"Moving: {old_path}")
    print(f"-> {new_path}")
    shutil.move(old_path, new_path)

print("Flattening complete.")
```

✦ I will now execute the script to move and rename the files.

  ✓  Shell python3 ~/.gemini/tmp/ai-shell/flatten_novel.py

```sh
... first 58 lines hidden (Ctrl+O to show) ...

Moving: ~/Documents/Novel/Original/Species - Shadow.doc.docx
-> ~/Documents/Novel, Original, Species - Shadow.docx

Moving: ~/Documents/Novel/Original/Chapter 08 - First Contact.doc.docx
-> ~/Documents/Novel, Original, Chapter 08 - First Contact.docx

Moving: ~/Documents/Novel/Original/Species - Bears.doc.docx
-> ~/Documents/Novel, Original, Species - Bears.docx

Moving: ~/Documents/Novel/Original/Other - Characters.doc.docx
-> ~/Documents/Novel, Original, Other - Characters.docx

Moving: ~/Documents/Novel/Original/Other - Humanity.doc.docx
-> ~/Documents/Novel, Original, Other - Humanity.docx

Moving: ~/Documents/Novel/More/Converse bites.docx
-> ~/Documents/Novel, More, Converse bites.docx
```

✦ I will check for any remaining files and then remove the now-empty directories in the Novel folder.

  ✓  Shell find "~/Documents/Novel" -type f && find "~/Documents/Novel" -type d -empty -delete

✦ I will now list the files in the base directory to verify the results of the flattening and renaming.

  ✓  Shell ls "~/Documents/"

```sh
... first 16 lines hidden (Ctrl+O to show) ...
'Novel, Original, Chapter 07 - Alien Technology.docx'
'Novel, Original, Chapter 08 - First Contact.docx'
'Novel, Original, Chapter 09 - Total Annihilation.docx'
'Novel, Original, Chapter 10 - The Forge.docx'
'Novel, Original, Appendix 01 - Rat Scourge.docx'
'Novel, Original, Appendix 02 - Alien Children.docx'
'Novel, Original, Back Cover.docx'
'Novel, Original, Ideas - Concepts.docx'
'Novel, Original, Ideas - Scenes.docx'
'Novel, Thoughts, 1st Thoughts.docx'
'Novel, Thoughts, 2nd Thoughts.docx'
'Novel, Thoughts, 3rd Thoughts.docx'
'Novel, Thoughts, 4th Thoughts.docx'
'Novel, Thoughts, Additions 1.docx'
'Novel, Thoughts, Additions 2.docx'
'Novel, Thoughts, Additions 3.docx'
'Novel, Thoughts, Additions 4.docx'
'Novel, To do.docx'
```

✦ I have successfully flattened the files, renamed them by converting path delimiters to commas, and corrected the ".doc.docx" extensions.

  ✓  Shell rm ~/.gemini/tmp/ai-shell/flatten_novel.py

✦ The files in ~/Documents/Novel and its subfolders have been flattened into ~/Documents/.

The folder structure was preserved in the filenames by replacing path delimiters with , , and all .doc.docx extensions were corrected to .docx. The original Novel directory and its subdirectories have been emptied and removed.

## Example of Usage 2
Here's another example of what you can do with AI-Shell. The user provided the following prompt:

> Please convert all ".docx" files in @~/Documents/ to PDF.

The AI-Shell then performed the following steps:
1.  Found all `.docx` files in the specified directory.
2.  Checked for the availability of LibreOffice.
3.  Used LibreOffice in headless mode to convert all found `.docx` files to PDF.
4.  Verified that the PDF files were created successfully.

This demonstrates the AI-Shell's ability to use external tools like LibreOffice to accomplish tasks that go beyond simple shell commands.

### Full Example 2
Here is the full transcript of the interaction.

> Please convert all ".docx" files in @~/Documents/ to PDF.

  ✓  ReadManyFiles  Attempting to read files from ../../Documents/** → Read 48 file(s) (12 ignored)

✦ I will first search for all .docx files in the specified directory to confirm the current file names.

  ✓  Shell find "~/Documents" -name "*.docx"

```sh
... first 39 lines hidden (Ctrl+O to show) ...
~/Documents/Novel, Original, Other - Timeline.docx
~/Documents/Novel, Original, Other - Characters.docx
~/Documents/Novel, Thoughts, Additions 1.docx
~/Documents/Novel, Original, Chapter 07 - Alien Technology.docx
~/Documents/Novel, Original, Chapter 02 - The Fish.docx
~/Documents/Novel, Original, Chapter 08 - First Contact.docx
~/Documents/Novel, Original, Chapter 04 - The Wilderness.docx
~/Documents/Novel, Original, Chapter 09 - Total Annihilation.docx
~/Documents/Novel, Appendix, The Unifying Axiom.docx
```

✦ I will check for the availability of LibreOffice to facilitate the file conversion.

  ✓  Shell libreoffice --version

```sh
LibreOffice 24.2.7.2 420(Build:2)
```

✦ I will use LibreOffice in headless mode to convert all .docx files in the directory to PDF format.

  ✓  Shell Convert all .docx files to PDF using LibreOffice.

```sh
... first 88 lines hidden (Ctrl+O to show) ...
Novel, Original, Chapter 02 - The Fish.pdf using filter : writer_pdf_Export
convert ~/Documents/Novel, Original, Chapter 08 - First Contact.docx as a Writer document -> ~/Documents/
Novel, Original, Chapter 08 - First Contact.pdf using filter : writer_pdf_Export
convert ~/Documents/Novel, Original, Chapter 04 - The Wilderness.docx as a Writer document -> ~/Documents/
Novel, Original, Chapter 04 - The Wilderness.pdf using filter : writer_pdf_Export
convert ~/Documents/Novel, Original, Chapter 09 - Total Annihilation.docx as a Writer document -> ~/Documents/
Novel, Original, Chapter 09 - Total Annihilation.pdf using filter : writer_pdf_Export
convert ~/Documents/Novel, Appendix, The Unifying Axiom.docx as a Writer document -> ~/Documents/Novel,
 Appendix, The Unifying Axiom.pdf using filter : writer_pdf_Export
```

✦ I'll now verify that the PDF files were correctly generated.

  ✓  Shell find "~/Documents" -name "*.pdf"

```sh
... first 40 lines hidden (Ctrl+O to show) ...
~/Documents/Novel, Original, Chapter 04 - The Wilderness.pdf
~/Documents/Novel, Original, Appendix 02 - Alien Children.pdf
~/Documents/Novel, Thoughts, Additions 4.pdf
~/Documents/Novel, Bullet-pointed mind map.pdf
~/Documents/Novel, Outlier Existence.pdf
~/Documents/Novel, Thoughts, 2nd Thoughts.pdf
~/Documents/Novel, Original, Species - Horses.pdf
~/Documents/Novel, Original, Appendix 01 - Rat Scourge.pdf
~/Documents/Novel, Original, Other - Timeline.pdf
```

✦ All .docx files in ~/Documents/ and its subdirectories have been converted to PDF.

The new PDF files are located in the same directory as the original .docx files, following the naming convention established in the previous step. The conversion was performed using LibreOffice in headless mode.
