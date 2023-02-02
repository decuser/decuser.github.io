---
layout: post
title:  "A Modern PDF Cleanup Workflow"
categories: pdfs
---

This note provides a workflow for taking a less than optimized PDF and optimizing it for viewing and printing. It isn't a cure-all for sick PDF's, but it does work for a lot of them. I've struggled with badly scanned PDF's for a long time and this workflow represents my current best approach.

The note also provides a cookbook of solutions to problems I have run up against and the solutions that I currently use to address those problems.

<!--more-->

## Caveats

Not many, but they're important to note

* Every PDF is unique and no one solution fits them all
* The workflow is a MacOS workflow. It should translate to the BSD's and Linuxes without much difficulty. If you're on Windows, YMMV.

## Packages

A variety of tools are useful if you are going to work with scanned images and pdfs. This note uses PhotoScape X to deal with Color adjustments. Feel free to use your tool of choice. If you can achieve good results with one of the other packages, drop me a line, I'll happily change my workflow.

* *ghostscript* - pdf tools
* *ImageMagick* - conversion tools for images
* *libtiff* - tiff tools
* *mupdf* - more pdf tools
* *poppler* - more pdf tools
* *pandoc* - coversion tools for documents
* *PhotoScape X* - app that does nice batch operations on images
* *tesseract* and *tesseract-eng* - OCR tools

**Install Packages**

Get PhotoScape X. It's available in the Apple App Store and the free version works great. I just downloaded it and archived off a copy of the app for later use as neeed. I am not a fan of apps, but this one is too good to ignore.

The other packages are available via macports:

```
sudo port install ghostscript ImageMagick libtiff mupdf poppler pandoc tesseract tesseract-eng
```

## Short Version

Here is the short version, keep reading afterward for details and the cookbook. There are lots of details to follow. This pdf stuff is tricky. Testing is very time consuming and great results are hard to obtain. This is my current workflow for taking a less than optimal pdf and improving it. Caveats apply.

### 1. Phase One

* Create a work area
* Copy in a pdf
* Extract tiffs

    ```
mkdir -p ~/pdf-work/{input,output,output-photoscape,output-small,output-ocr}
cd ~/pdf-work/input
cp ~/Desktop/input.pdf .
cd ../input
pdfimages -tiff -p input.pdf ../output/output
```
### 2. Phase Two

* Use PhotoScape to adjust colors
  * Open PhotoScape X
  * Click Batch
  * Drag the *output* folder into the window
  * Choose Color->Grayscale
  * Magic Color
  * Lighten Shadows - 100
  * Darken Highlights - 50
  * Click SAVE
  * Change the Image Format to TIFF
  * Select DPI and change it to 150
  * Choose a custom destination to put the output (output-photoscape)
  * Click OK

### Phase Three

* Resize and compress the tiffs
* Combine the tiffs into a single tiff
* OCR the single tiff and produce the OCR'ed PDF

    ```
cd ../output-photoscape
for i in *.tiff; do convert $i -resize 1200x -compress zip ../output-small/$i.tiff;done
cd ../output-small
tiffcp *.tiff ../input/multi-image-input.tiff
cd ../input
tesseract multi-image-input.tiff ../output -l eng PDF
```

The result is found in *output.pdf*

## The Details

The following gets into the details about working with a not-so-great scanned pdf, trying to make it better and more useful - cleaner looking and with OCR. In the following discussion, I will be using a copy of Adrian Nye's Volume 4 of *The Definitive Guides to the X Window System* about Xt Intrinsics from [archive.org](https://archive.org/details/xtoolkitintrinsic04nyemiss). This PDF is particularly suited to being reworked. It has huge images, it's color, the color is neither needed, nor clear, it isn't OCR'ed, and it's a great book.

**Tools provided by the packages**

We will use a variety of tools in the exploration. Here is a summary list:

* *convert* from the package *ImageMagick*, convert between image formats 
* *gs* from the package *ghostscript*, extract images from pdf (single image tiffs)
* *mutool* from the package *mupdf* - get info about images in pdf
* *pandoc* from the package *pandoc*, convert document formats (pdf, html, markdown, latex, etc)
* *pdfimages* from the package *poppler*, extract images from pdf (multi image tiff) and get info about images in pdf
* *pdfinfo* from the package *poppler*, get info from pdf
* *pdfunite* from the package *poppler*, combine pdfs into a single pdf
* *PhotoScape X* from the app *PhotoScape X*, color adjustment
* *tesseract* from the package *tesseract*, OCR of images and creation of pdf
* *tiffcp* from the package *libtiff*, combinine single-image tiffs into a multi-image tiff
* *tiffsplit* from the package *libtiff*, split multi-image tiffs into single-image tiffs

### 1. Setting up a work area

Make a directory to work from (preferably on an SSD) with input and output subdirs, change into it, download our work of interest, and copy it to *input.pdf* to use as our source.

```
mkdir -p ~/pdf-work/{input,output,output-photoscape,output-small,output-ocr}
cd ~/pdf-work

aria2c https://archive.org/download/xtoolkitintrinsic04nyemiss/xtoolkitintrinsic04nyemiss_200KB_jp2.pdf -o nye-vol-04.pdf

cp nye-vol-04.pdf input/input.pdf
```

You might want to just use preview to drag a sampling of the pages into a pdf that you name input.pdf and work with that until you're convinced you want to work with the many, many page input.pdf :).

### 2. Getting Information from a PDF

Let's take a look at the meta-data about the PDF using *pdfinfo* from the *poppler* package.

```
pdfinfo input.pdf
...
Producer:        iText 1.3 by lowagie.com (based on itext-paulo-153)
CreationDate:    Sun Jan  8 00:02:44 2006 CST
ModDate:         Sun Jan  8 00:02:44 2006 CST
Custom Metadata: no
Metadata Stream: no
Tagged:          no
UserProperties:  no
Suspects:        no
Form:            none
JavaScript:      no
Pages:           622
Encrypted:       no
Page size:       475 x 637 pts
Page rot:        0
File size:       127682751 bytes
Optimized:       no
PDF version:     1.5
```

The first things to notice are *Pages*, *Page size*, and *File size*:

```
Pages:           622
Page size:       475 x 637 pts
File size:       127682751 bytes
```

This is one big pdf!

Note that points are 1/72 of an inch. We can use the `units` command to find the conversion factors:

```
units point in
	* 0.013888889
	/ 72
```

We can then do the math to figure out the size, in inches, of the pdf:

```
echo '475/72' | bc -l
6.59722222222222222222

echo '637/72' | bc -l
8.84722222222222222222
```

So, it's a 6.5x9 pdf (I'm not convinced, but that's what the pdf thinks it is, so we'll roll with it).

### 3. Getting information about a PDF's images

For this, we can use *mutool* from the *mupdf* package and *pdfimages* from the *poppler* package.

Let's start with *mutool*. this utility will display information about all of the images in a pdf, so be prepared for some lenghty output:

```
mutool info input.pdf
input.pdf:

PDF-1.5
Info object (1939 0 R):
<</CreationDate(D:20060108060244Z)/Producer(iText 1.3 by lowagie.com \(based on itext-paulo-153\))/ModDate(D:20060108060244Z)>>
Pages: 622

Retrieving info from pages 1-622...
Mediaboxes (15):
	1	(4 0 R):	[ 0 0 475 637 ]
	2	(7 0 R):	[ 0 0 455 630 ]
	42	(131 0 R):	[ 0 0 461 629 ]
	48	(149 0 R):	[ 0 0 464 632 ]
	50	(155 0 R):	[ 0 0 457 632 ]
	52	(162 0 R):	[ 0 0 468 637 ]
	54	(168 0 R):	[ 0 0 466 636 ]
	74	(230 0 R):	[ 0 0 471 639 ]
	128	(397 0 R):	[ 0 0 465 637 ]
	162	(503 0 R):	[ 0 0 458 642 ]
	198	(614 0 R):	[ 0 0 461 639 ]
	200	(620 0 R):	[ 0 0 468 642 ]
	316	(980 0 R):	[ 0 0 468 638 ]
	332	(1030 0 R):	[ 0 0 471 638 ]
	490	(1519 0 R):	[ 0 0 463 638 ]

Images (622):
	1	(4 0 R):	[ JPX ] 2644x3542 1bpc ImageMask (1 0 R)
	2	(7 0 R):	[ JPX ] 2528x3502 1bpc ImageMask (5 0 R)
...
```

There is a lot of information being displayed. But, we're mostly concerned with the image resolutions at this point.

Pixels are picture elements and they don't readily convert to more intuitive units like inches. But, we can do a conversion for the monitor that'll give us a hint as to the actual size.

First, let's get the dpi information from X (go get XQuartz and install it, if you don't already have it):

```
xdpyinfo | grep dots
resolution:    96x96 dots per inch
```

and

```
xrandr | grep -w connected
default connected 2560x1440+0+0 0mm x 0mm
```

This tells us how many dots per inch our monitor has and how many dots there are both horizontally and vertically.

Converting to inches is pretty straightforward since we now know the DPI and dots:

```
echo '2560/96' | bc -l
26.66666666666666666666
(base) nebula:~ wsenn$ echo '1440/96' | bc -l
15.00000000000000000000
```

This monitor is 27 x 15... get the measuring tape out... I wish, it's actually 23.5 x 13.25. Prolly some weird pixel thing... Not worth worrying about, it's close enough :). Email me if you know something useful here.

The question is how big is that image in relation to what we know about the monitor:

```
echo '2600/96' | bc -l
27.08333333333333333333
echo '3500/96' | bc -l
36.45833333333333333333
```

27 in x 36.5 in

Wow! That's huge :). It's about the same width as my monitor and more than twice as tall. Way more than we need for viewing or printing.

Similarly, we can get image information using *pdfimages* from the *poppler* package:

```
pdfimages -list input.pdf 
page   num  type   width height color comp bpc  enc interp  object ID x-ppi y-ppi size ratio
--------------------------------------------------------------------------------------------
   1     0 image    2644  3542  rgb     3   8  jpx    no         1  0   401   400  200K 0.7%
   2     1 image    2528  3502  rgb     3   8  jpx    no         5  0   400   400  200K 0.8%
```

*pdfimages* is a lot slower than *mutools*, but we do get some additonal information making it a good utility to have around.

### 2. Extracting images from a PDF

To extract images, we can use *pdfimages* from the *poppler* package:

```
cd ~/pdf-work/input
pdfimages -tiff -p input.pdf ../output/output
```

This will extract all of the images from the pdf and put them into *../output*. The images will be named 'output-XXX-YYY.tif'. If there are a lot of big images, it will take a while... and use a lot of disk space to extract them all, so be patient.

### 3. Tweaking colors

I'm sure there are better ways to do this, I just haven't figured them out yet. Email me with your tips. The command-line tools don't seem to know about "magic color". Twiddle as you like with Lighten/Darken, etc.

To tweak colors, we can use *PhotoScape X* and preview our tweaks in real-time:

* Open PhotoScape X
* Click Batch
* Drag the *output* folder into the window
* Choose Color->Grayscale
* Magic Color
* Lighten Shadows - 100
* Darken Highlights - 50
* Click SAVE
* Change the Image Format to TIFF
* Select DPI and change it to 150
* Choose a custom destination to put the output (output-photoscape)
* Click OK

Be patient. It'll work.

### 4. Resizing images

I am going to resize the images to 1200 pixels wide and I'm going to preserve the scaling. I am also going to compress the images. You may want to tweak the size. We will use the *convert* utility from the *ImageMagick* package:

```
cd ~/pdf-work/output-photoscape
for i in *.tiff; do convert $i -resize 1200x -compress zip ../output-small/$i.tiff;done
```

1200x might not be your speed, just change it as you see fit. I'm still trying to figure out an optimal size.

Be patient, it'll take a bit.

### 5. Recombining single-image tiffs

To combine a bunch of individual tiffs into a multi-image tiff suitable for additional processing, we will use *tiffcp* from the *libtiff* package:

```
cd ~/pdf-work/output-small
tiffcp *.tiff ../input/multi-image-input.tiff
```

### 6. OCRing the images

We will be using *tesseract* from the *tesseract* package to perform OCR on our images. *tesseract* will work with either single-image tiffs or with a multi-image tiff. I will show both options, but for the workflow, we will only be concerned with the multi-image tiff version (a single file with many images).

**Option 1. Multi-image tiffs**

```
cd ~/pdf-work/input
tesseract multi-image-input.tiff ../output -l eng PDF
```

**Option 2. Single-image tiffs**

**Don't do this if you did option 1!**

```
cd ~/pdf-work/output-small
for i in *.tiff; do tesseract $i ../output-ocr/$i -l eng PDF;done
```

Using option 2, there will be lots of pdfs to combine. We will use *pdfunite* from the *poppler* package to do the combination:

```
cd ~/pdf-work/output-ocr
pdfunite *.pdf ../output.pdf
```

Either option will take quite a while and both will produce an OCR'ed PDF.

The result is a cleaner, better looking, and more functional PDF.

That's it for the exploration! On to the cookbook!

---

## Cookbook Solutions to various problems

This section provides snippets solving specific problems arising while working with pdf's and images.

### Extract images to single-image tiff files

`pdfimages -tiff -p input.pdf output`

This creates a bunch of tiff images named output-XXX-YYY.tif

### Extract images to a multi-image tiff file

```
gs -q -dNOPAUSE -dBATCH -sDEVICE=tifflzw -sPAPERSIZE=letter \
    -sOutputFile=output.tiff input.pdf
```

This will extract all of the images in a pdf into a single .tiff

A useful option to keep in mind is *-r* for resolution. A setting like *-r300* specifies a desired DPI.

### Combine single-image tiffs into a multi-image tiff

`tiffcp -c zip *.tif ../output.tiff`

This combines all of the .tif files into a single .tiff

### Adjust Colors of Multiple Images at Once

* open *PhotoScape X* to batch correct the color
 * click batch
 * add in your image folder
 * adjust colors
 * save the results

This creates a bunch of tiff images named whatever-XXX-YYY.tiff

### OCR a .tiff file and produce a PDF

The accuracy of tesseract rivals adobe now... finally. 

`tesseract input.tiff output -l eng PDF`

### Split a multi-image tiff into single-image tiffs

`tiffsplit input.tiff`

This will extract all of the images from the tiff into multiple tiffs with funky names like *xaaa.tif* *xaab.tif* and so on, but it does what it says :).

### Resize multiple tiffs

`for i in *.tif; do convert $i -resize 1200x ../$i.tiff;done`

This resizes tiffs to 1200xwhatever preserving the scale.

### Resize multi-image tiff

`convert input.tiff -resize 1200x output.tiff`

This does the same thing for a multi-image tiff.

### Join PDFs

**Option 1 - using *pdfunit* from the *poppler* package**

`pdfunite *.pdf ../output.pdf`

This joins all of the pdf files in a directory into a single pdf. It presumes that the pdfs are numbered appropriately so they are in sort order.

**Option 2 - using MacOS's delivered script**

* deactivate any python environments you have running that aren't the system python
* run the script

```
conda deactivate
python '/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py' -o 'senn_w_database_project.pdf' [your list of pdfs]
```

Reach out to me if you find any issues or have suggestions.

\- will

*post last updated 2023-02-01 20:39:00 -0600*
