# figCapture: A MATLAB GUI for Saving Figures

This repository provides a MATLAB GUI named `figCapture` for easily saving figures with user-defined settings. It simplifies the process of exporting figures by offering an intuitive interface to specify file format, save location, and filename.

## Features

*   **GUI-based operation:** All settings and actions are managed within a graphical user interface.
*   **Customizable settings:**
    *   Choose from various file formats (e.g., PNG, JPG, PDF).
    *   Specify the desired save directory.
    *   Define the filename, with a timestamp-based default.
*   **Persistent configuration:** Settings are saved in a configuration file (`config`) and loaded upon subsequent launches, preserving user preferences.
*   **Automatic figure selection:** Saves the currently active figure (obtained via `gcf`).

## Install
To clone to your own MATLAB Drive, click on the following icon
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=MyMatTool/figCapture)

## Usage

1.  Launch MATLAB.
2.  In the command window, type `figCapture` and press Enter.
   ```matlab
   >> figCapture
   ```
4.  The GUI will open, allowing you to adjust settings.
5.  Click the "Capture" button to save the figure.

## Configuration

*   The `config` file stores the preferred file format and save location.
*   This file is updated whenever settings are modified within the GUI.

## Default Filename

The default filename includes the date and time of the GUI launch, ensuring unique names for each saved figure.



## Demo
<img src="https://github.com/user-attachments/assets/9066912c-5b7f-4b6f-9c2f-64154b5a9288" width="70%">


