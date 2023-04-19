# Word Segmentation

As of April 2023, there is one script to run for the word segmentation workflow: **word_segmentation.py**. This script:
1. Copies the `<div type="edition" subtype="transcription">` into a new `<div type="edition" subtype="transcription_segmented">` and surrounds every token in the inscription with either a `<w>`, `<num>`, or `<orig>` element (for words, numbers, and non-word tokens).
  * These `<w>`/`<num>`/`<orig>` elements have attributes indicating language and an ID that also has sequence information.
  * The `transcription_segmented` `<div>` includes a `change` attribute that automatically records the date of segmentation. This can be used to check when changes have been made subsequent to the original segmentation.
2. Takes all the tokens tagged as `<w>` words and outputs them into wordlist CSVs, divided by language, to be used later in the linguistic analysis workflow.

By default, running **word_segmentation.py** in this directory will take as input all the XML files in the `00unsegmented/` directory and output the updated XML files in the `01python_segmentation_out/` directory. It will output the wordlist CSVs in the `word_segmentation_lists/` directory. The script will print any errors it encounters in the terminal. It is best to copy and save this error output in an error file, to keep track of which files failed segmentation, what the errors were, etc.

## Preparing to run the segmentation script

To run this script, you will need to have [Python](https://www.python.org/downloads/) installed on your computer. You will also need the Python module `lxml`. If this is your first time running the script, install `lxml` with the following command in the command line:

> `pip install lxml`

## Running the segmentation script

Open the terminal or command line, navigate to the `word-segmentation/` directory, and use the following command to run the script:

> `python word_segmentation.py` 

If you get a Python error, try using Python 3. You will have to make sure it's installed on your computer.
  
> `python3 word_segmentation.py` 
  
If processing results in an invalid inscription file - the new, segmented div is invalid - that file will fail and won't be written out. A record of the file number and some indication of the error will be printed in the terminal. You can look through that output to see what the errors are and try to clean them up. The number of errors is printed at the bottom of this output. 

## Next steps

When this segmentation process is complete and you are satisfied that the transformations are okay, you should do the following.

  * Copy all the files from `01python_segmentation_out/` to `epidoc-files/`
  * Delete all the successfully segmented files from `00unsegmented/`, leaving only files that failed to be segmented. This keeps track of what files are still not segmented. 
  * Any new files that are put into `epidoc-files/` should also be put into `00unsegmented/` and the segmentation script should be run on them quickly. 
  * This plan allows files to get out of sync, so it is important to keep track of edits and use the change log. 
  * Files that have no transcription div (diplomatic only) are ignored by word segmentation and can just be placed in `epidoc-files/`. 

Note: the code does not yet handle `@textpart` divs.
