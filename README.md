# conv,sh

The Bash script is designed to process a landscape-oriented PDF where each page contains two vertically aligned pages. It begins by converting each page of the PDF into high-resolution PNG images using the pdftoppm tool. Each resulting image, representing two side-by-side pages, is then split into two separate vertical images (left and right) using ImageMagick’s magick command. To maintain the correct numerical order of pages, the script applies zero-padding to the page numbers, ensuring that pages 10, 11, 12, etc., are correctly sequenced after pages 1, 2, 3, and so forth.

After splitting the images, the script performs Optical Character Recognition (OCR) on each half-image using Tesseract in English (-l eng). The extracted text from each image is compiled into a single output text file. Each section of the text file is clearly labeled with headers indicating the original page number and whether the text was extracted from the left or right side. This organized approach ensures that the final text output is easy to navigate and accurately reflects the structure of the original PDF. Additionally, the script cleans up all temporary files and directories created during the process, leaving only the final consolidated text file.

# Installation Instructions

Required Packages

	1.	Poppler
	•	Provides the pdftoppm tool for converting PDF pages to images.
	2.	ImageMagick
	•	Offers the magick command for image manipulation (cropping, resizing, etc.).
	3.	Tesseract OCR
	•	Performs Optical Character Recognition to extract text from images.

For macOS Using Homebrew

If you don’t have Homebrew installed, you can install it by following the instructions on the Homebrew website or by running the following command in your Terminal:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Once Homebrew is installed, execute the following commands to install the required packages:

# Update Homebrew to ensure you have the latest package information
brew update

# Install Poppler for PDF conversion tools
brew install poppler

# Install ImageMagick for image manipulation
brew install imagemagick

# Install Tesseract OCR
brew install tesseract

# (Optional) Install additional language packs for Tesseract if needed
# For English, the default installation includes the 'eng' language
# If you need other languages, install them as follows:
brew install tesseract-lang

For Debian-based Linux Distributions Using APT

Ensure that your package list is up to date before installing new packages. Open your Terminal and run the following commands:

# Update the package list
sudo apt update

# Install Poppler-utils for PDF conversion tools (includes pdftoppm)
sudo apt install poppler-utils

# Install ImageMagick for image manipulation
sudo apt install imagemagick

# Install Tesseract OCR
sudo apt install tesseract-ocr

# (Optional) Install additional language packs for Tesseract if needed
# For English, the default installation includes the 'eng' language
# If you need other languages, install them as follows:
sudo apt install tesseract-ocr-eng
# Replace 'eng' with the appropriate language code for other languages, e.g., 'ita' for Italian

	Note: Depending on your Linux distribution, the ImageMagick command might still be convert if you’re using a version prior to ImageMagick 7. However, with ImageMagick 7 and later, the magick command is preferred. To ensure compatibility, you can create an alias or use magick directly in your scripts.

## Verification

After installation, verify that each tool is correctly installed by checking their versions:

# Verify Poppler (pdftoppm)
pdftoppm -v

# Verify ImageMagick (magick)
magick -version

# Verify Tesseract OCR
tesseract --version

You should see version information for each tool, confirming that they are installed and accessible from your Terminal.

Troubleshooting Tips

	•	ImageMagick Version:
	•	Ensure you have ImageMagick version 7 or later to use the magick command. You can check the version using:

magick -version


	•	If you have an older version, consider upgrading via Homebrew or APT.

	•	PATH Issues:
	•	If any of the installed tools are not recognized, ensure that Homebrew’s or APT’s binary directories are included in your system’s PATH environment variable.
	•	Permissions:
	•	On Linux, if you encounter permission issues when running the script or accessing certain directories, you might need to adjust file permissions or run commands with sudo.
	•	Language Packs:
	•	For Tesseract OCR, make sure the necessary language packs are installed. The default installation includes English (eng). If you need support for additional languages, install the corresponding language packages as shown above.

