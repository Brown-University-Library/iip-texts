There are two sets of files that are used in adding word segmentation infmation to the IIP files.
1. **word_segmentation.py** runs over a directory of IIP files. It copies the `<div type="edition" subtype="transcription">` into a new `<div type="edition" subtype="segmented-transcription">` and surrounds every word in the inscription with a `<w>` element. The `<w>` elements have attributes indicating language, an ID that also has sequence information, and ultimately, the lemma.

  `<w xml:id="achz0001-2" xml:lang="la">Caesar</w>`

  It is possible to set input and output folders for word_segmentation.py - see lines 27 and 28 of the script.
  It's best to run this script and save error output it in an error file, in order to see which files failed to be copied, what the errors were etc.

  `python word_segmentation.py > errors.txt`

  If processing results in an invalid inscription file, that file will fail and won't be written out. A record of the file number and some indication of the error will be written to  `errors.txt`.

  2. **IIP-cleanUpSegmentation.xsl** cleans up mistakes that the previous script leaves in. The input should be the output folder of word_segmentation.py and it outputs into `cleaned_segmentation_out` This is an XSL script that should be run using Saxon on the command line as follows, if you apply it to all the IIP files. It can be run using an XSL transform in Oxygen if it's only applied to a few files. Run on the command line as follows. Make sure to change the file paths so they reflect your own environment. The best way to handle that is to `cd` into each directory and run `pwd`. Use that string in the command below. The parameters are - *-s:* indicates the the directory with the source files; *-xsl:* indicates the xsl script; *-o:* indicates the output directory.

  `saxon -s:segmented-in -xsl:/Users/ellimylonas/Dropbox\ \(Brown\)/IIP\ Files/iip-git/scripts/IIP-cleanUpSegmentation.xsl -o:segmented-out/ -xi:off`

  3. **IIP_create_word_CSV.xsl** Uses the files in the output folder of the previous script to generate a CSV file, `out.csv`, with the inflected words, their ID and various other bits of information. Run this script as follows. As with the previous XSL script, it can be run using Saxon on the command line or in Oxygen. This script will is run on a single IIP file, but the processing reads all files and creates a CSV from all of them. The file used to run it is not significant

  `saxon -s:segmented-out/abil0001.xml -xsl:/Users/ellimylonas/Dropbox\ \(Brown\)/IIP\ Files/iip-git/scripts/IIP-create-word-CSV.xsl -o:csv-out/out.csv -xi:off`
