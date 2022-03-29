There are two sets of files that are used in adding word segmentation infmation to the IIP files.
1. **word_segmentation.py** runs over a directory of IIP files. It copies the `<div type="edition" subtype="transcription">` into a new `<div type="edition" subtype="segmented-transcription">` and surrounds every word in the inscription with a `<w>` element. The `<w>` elements have attributes indicating language, an ID that also has sequence information, and ultimately, the lemma.

  `<w xml:id="achz0001-2" xml:lang="la">Caesar</w>`

  It is possible to set input and output folders for word_segmentation.py - see lines 27 and 28 of the script. Right now, the input folder is set to be `00unsegmented` and the output folder is `01python_segmentation_out`
  It's best to run this script and save error output it in an error file, in order to see which files failed to be copied, what the errors were etc.
  
  Run the script from the `word-segmentation` directory.

  `python word_segmentation.py > errors.txt` 
  
  If you get a python error, try using python 3. You will have to make sure it's installed on your computer.
  `python3 word_segmentation.py > errors.txt` 
  
  If you get a python error, try using python 3. You will have to make sure it's installed on your computer.
  `python3 word_segmentation.py > errors.txt`
  
 If processing results in an invalid inscription file - the new, segmented div is invalid - that file will fail and won't be written out. A record of the file number and some indication of the error will be written to  `errors.txt`. You can look in that file to see what the errors are and try to clean them up. The number of errors is printed at the bottom of the file. 
  
  2. **IIP-cleanUpSegmentation.xsl** cleans up mistakes that the previous script leaves in. The input should be the output folder of word_segmentation.py (`01python_segmentation_out`). Using the command below, the output will be written to `02cleaned_segmented-out`. This is an XSL script that should be run using Saxon on the command line as follows, if you apply it to all the IIP files. It can be run using an XSL transform in Oxygen if it's only applied to a few files. It takes too long otherwise. Run on the command line as follows. Make sure to change the file paths so they reflect your own environment. The best way to figure out the correct file path is to `cd` into each directory and run `pwd`. Use that string in the command below. The parameters are - *-s:* indicates the the directory with the source files; *-xsl:* indicates the xsl script; *-o:* indicates the output directory. 
  
  `saxon -s:00unsegmented -xsl:/Users/emylonas/Projects/iip/iip-git/scripts/IIP-cleanUpSegmentation.xsl -o:02cleaned_segmented-out`/ -xi:off`
  
  3. **IIP_create_word_CSV.xsl** Uses the files in the output folder of the previous script (`02cleaned_segmented-out`) to generate a CSV file, `word-list-out.csv`, with the inflected words, their ID and various other bits of information. The name of the output file is specified as part of the Saxon commang, so it can be whatever makes sense. Run this script as follows. As with the previous XSL script, it can be run using Saxon on the command line or in Oxygen. This script will is run on a single IIP file, but the processing reads all files and creates a CSV from all of them. The file used to run it is not significant
  
  `saxon -s:02cleaned_segmented-out/abil0001.xml -xsl:/Users/emylonas/Projects/iip/iip-git/scripts/IIP-create-word-CSV.xsl -o:word-list-out.csv -xi:off`
  
 This script uses a single inscription file as a place to start running. In the example above, it is `abil0001.xml`, however, you should use any file that is in the `02cleaned_segmented-out` directory. abil0001.xml has already been processed and is not likely to be there. 
 
4. When this process is complete and you are satisfied that the transformations are ok you should do the following.

    * We need to add the date when segmentation was performed to the div, so we know if changes have been made subsequent to that. It could also be put into the change log. Right now, it's a global change. See current files for example.
    * Copy all the files from `02cleaned_segmented-out` to `epidoc-files`
    * Delete all the successfully segmented files from `00unsegmented`, leaving only files that failed to be segmented. This keeps track of what files are still not segmented. 
    * Any new files that are put into `epidoc-files` should also be put into `00unsegmented` and the segmentation should be run on them quickly. 
    * This plan allows files to get out of sync, so it is important to keep track of edits and use the change log. 
    * Flles that have no transcription div (diplomatic only) are ignored by word segmentation and can just be placed in `epidoc-files`. 
    * We still don't handle `@textpart` divs.
