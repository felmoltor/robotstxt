Robots TXT Dictionary generator
===============================

This script requests all the robots.txt of a list of domains.
Obtains the Disallow entries and order them by frequency.
The resultant dictionary can be used in web fuzzing.

Usage
-----

Usage: ./robotstxt.sh &lt;domains file&gt;

Output
------

The "output" folder will be created with the following 4 files:
- robots.entries.txt: Contains, sorted by descending frequency the disallowed full entries of the explored domains
- robots.sorted.files.txt: Contains, sorted by descending frequency the disallowed file names of the explored domains
- robots.sorted.full.path.txt: Contains, sorted by descending frequency the disallowed full path entries of the explored domains
- robots.sorted.rootfolder.txt: Contains, sorted by descending frequency the disallowed root folder entries of the explored domains
