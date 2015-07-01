from itertools import groupby
import sys
# Script to quickly remove duplicate fasta-entries, based
# on duplicate handles
# Arg 1: Input-fasta
# Arg 2: Output-fasta

inname = sys.argv[1]
oname = sys.argv[2]

if __name__ == '__main__':

    ishead = lambda x: x.startswith('>')
    all_seqs = set()
    with open(inname) as handle:
        with open(oname, 'w') as outhandle:
            head = None
            for h, lines in groupby(handle, ishead):
                if h:
                    head = lines.next()
                else:
                    seq = ''.join(lines)
                    if seq not in all_seqs:
                        all_seqs.add(seq)
                        outhandle.write('%s\n%s\n' % (head.rstrip(), seq.rstrip()))
