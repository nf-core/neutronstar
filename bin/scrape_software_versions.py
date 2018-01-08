#!/usr/bin/env python
from __future__ import print_function
from collections import OrderedDict
import re

regexes = {
    'NGI-NeutronStar': ['v_pipeline.txt', r"(\S+)"],
    'Nextflow': ['v_nextflow.txt', r"(\S+)"],
    'MultiQC': ['v_multiqc.txt', r"multiqc, version (\S+)"],
    'Supernova': ['v_supernova.txt', r"supernova run \((\S+)\)"],
    'Quast': ['v_quast.txt', r"QUAST v(\S+)"],
    'Busco': ['v_busco.txt', r"BUSCO (\S+)"],
}
results = OrderedDict()
results['NGI-NeutronStar'] = '<span style="color:#999999;\">N/A</span>'
results['Nextflow'] = '<span style="color:#999999;\">N/A</span>'
results['MultiQC'] = '<span style="color:#999999;\">N/A</span>'
results['Supernova'] =  '<span style="color:#999999;\">N/A</span>'
results['Quast'] = '<span style="color:#999999;\">N/A</span>'
results['Busco'] = '<span style="color:#999999;\">N/A</span>'


# Search each file using its regex
for k, v in regexes.items():
    try:
        with open(v[0]) as x:
            versions = x.read()
            match = re.search(v[1], versions)
            if match:
                results[k] = "v{}".format(match.group(1))
    except FileNotFoundError:
        pass

# Dump to YAML
print ('''
id: 'ngi-neutronstar-software-versions'
section_name: 'NGI-NeutronStar Software Versions'
section_href: 'https://github.com/scilifelab/NGI-NeutronStar'
plot_type: 'html'
description: 'are collected at run time from the software output.'
data: |
    <dl class="dl-horizontal">
''')
for k,v in results.items():
    print("        <dt>{}</dt><dd>{}</dd>".format(k,v))
print ("    </dl>")
