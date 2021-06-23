# Usage for wordlist.py

## Basic Usage

This script takes as arguments a list of XML files to process. By default, it will print output to stdout in a table with cells seperated by a pipe. Regular expressions for shell expansion are very useful to process a number of files at once.

ex) `./src/python/wordlist.py docs/texts/xml/*` will process all of the site's data files.

## Flags

Flags can be viewed by running `python3 wordlist.py --help`.

### Output Flags

`--html_general` is used in building the site. It will create a directory for each language encountered in the XML files. Directories will be created in the directory where the script was invoked. In each language directory, there will be created html files containing information on each word encountered, as well as an index file to listing each item.

`--html` produces one or more html pages containing a table containing a row for each word occurence. Several columns are missing, and this option is made mostly obsolete by `--html_general`. 

`--csv` outputs a file listing all word occurences, but unlike the above option, it includes more complete information. In both cases, the file is created in the directory from which the script is invoked.

ex) Running `./src/python/wordlist.py docs/texts/xml/* --csv`from the project root will create a file called word_occurences.csv containing occurence data.

`--sort <sortorder>` sorts the data produced by `--html` or `--csv`. <sortorder> specifies the order in which fields should be used to sort the data. Each field is represented by a single character:

* l : language
* t : text
* f : file name
* e : edition type

ex) `--sort ltfe` will sort first by language, then by text, then by file name, then by edition type.

`--plaintext` will by default create two directories, `flat` and `flat_lemma` in the directory from which the script was invoked. In each directory, there will be createdtext files with names derived from the XML files processed. Each text file will contain the words extracted from the corresponding xml file in order. Words within a `<div type="translation">` tag will be written to a seperated file with `_transl` appended to the file name. The `flat_lemma` directory contains files where each word is written in its lemmatized form - this is intended to facilitate natural language processing.

`--nolemma` will cause the content of the `flat_lemma` directory to use the actual form of the word occurence instead of the lemma. This should be changed so that it will instead prevent the `flat_lemma` directory from being created at all.

`--flat NAME` will change the name of the directory where the files created by `--plaintext` are stored to `NAME`. This can be a path, in which case directories in the path name will be created.

### Processing Flags

`--old_system` will cause the words to be identified based on information provided by the LXML ElementTree. This was faster, but was difficult to reason about and was replaced by a character-based approach. This may still be useful for checking against the current results. Previously, this was the default and the current system was invoked by `--new_system`

`--nodiplomatic` will cuase the word extraction to omit text marked as "diplomatic," which indicates that it was transcribed with the intention of representing the inscription text exactly as it was written. Including such text is often not desirable as it will omit information useful for word extraction such as whitespace.

`--engstops` will cause any words in the english stop list to be ommitted from the output. The stop list contains common English grammatical words such as "the". For some uses, for instance, comparing word frequency in different geographic regions, it is useful to omit these words, as they are unlikely to provide meaningful insight on the subject being studied.

### Misc Flags

`--repl` starts a read-execute-print loop after the processing has been done. This is meant to allow easier command-line access to extracted data, however currently the gui is complete enough that this is largely unnecessary.

