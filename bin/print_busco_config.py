#!/usr/bin/env python
from __future__ import print_function
import os
print(
"""[busco]
out_path = {0}
tmp_path = {0}/tmp

[tblastn]
# path to tblastn
path = /usr/bin/

[makeblastdb]
# path to makeblastdb
path = /usr/bin/

[augustus]
# path to augustus
path = /opt/augustus/bin/

[etraining]
# path to augustus etraining
path = /opt/augustus/bin/

# path to augustus perl scripts, redeclare it for each new script
[gff2gbSmallDNA.pl]
path = /usr/bin/ 
[new_species.pl]
path = /usr/bin/ 
[optimize_augustus.pl]
path = /usr/bin/ 

[hmmsearch]
# path to HMMsearch executable
path = /usr/local/bin/ 

[Rscript]
# path to Rscript, if you wish to use the plot tool
path = /usr/bin/""".format(os.environ['PWD'])
)
