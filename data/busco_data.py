#!/usr/bin/env python
from __future__ import print_function
import os
import json
import argparse
import subprocess
from itertools import chain

def get_pretty(url):
    pretty_name = url.split('/')[-1]
    return pretty_name.split(".tar.gz")[0]
    

if __name__ == '__main__':
    buscos = {} 
    try:
        with open("buscov2datasets.json", "r") as f:
            buscos = json.loads(f.read())
    except IOError:
        print("Missing buscov2datasets.json file")
        exit(1)

    categories = [v for v in chain.from_iterable( (buscos.values()) )]
    categories.append("all")
    c_buscos = {k: [] for k in set(categories)}
    for k, v in buscos.items():
        for i in v:
            c_buscos[i].append(k)
        c_buscos["all"].append(k)


    parser = argparse.ArgumentParser(description="Script to download Busco v2 data sets. "
            "For an overview of the datasets available, see: http://busco.ezlab.org/\n\n"
            "There are two special categories of datasets:\n"
            "   - all: Every dataset avaiable in BUSCO (These can use up a lot of diskspace)\n"
            "   - minimal: These are smaller datasets containing only higher taxa orthologs",
            formatter_class=argparse.RawTextHelpFormatter)
    subparsers = parser.add_subparsers(help='sub-command help')

    parser_l = subparsers.add_parser('list', help='list datasets by category')
    parser_l.add_argument('list_category', choices=sorted(set(categories)), help='list help')

    parser_d = subparsers.add_parser('download', help='download a category of datasets')
    parser_d.add_argument('download_category', choices=sorted(set(categories)), help='download help')

    args = parser.parse_args()

    if "list_category" in args:
        print("Category {} contains:".format(args.list_category))
        for i in c_buscos[args.list_category]:
            print("  - {}".format(get_pretty(i)))

    if "download_category" in args:
        print("## downloading category {}".format(args.download_category))
        for url in c_buscos[args.download_category]:
            wget = subprocess.Popen(['wget', '-O', '-', url], stdout=subprocess.PIPE)
            tar = subprocess.Popen(['tar', 'zx'], stdin=wget.stdout)
            output = tar.communicate()
        print("## finished downloading")

