from __future__ import print_function
import sys, re, numpy

# Script to extract the following info from AUGUSTUS(V3.0.1) gff3-output:
#    basename.fa:
#       all found sequences in fasta-format, handle is the DNA-handle
#    basename.stats:
#       stats on found genes (mean, sd, sum of DNA- and Protein-length), for
#       both global (also non-coding seqs) and coding-only scale.
# Arg 1: Input-GFF3
# Arg 2: basename
inputGFF3 = open(sys.argv[1],'r')
basename = str(sys.argv[2])

def warning(*objs):
    print("WARNING: ", *objs, file=sys.stderr)

def note(*objs):
    print("NOTE:    ", *objs, file=sys.stderr)

def group_by_heading( some_source ):
    buffer= []
    for line in some_source:
        if line.startswith( "# ----- prediction" ):
            if buffer: yield buffer
            buffer= [ line ]
        else:
            buffer.append( line )
    yield buffer

gffFound = False
for l in inputGFF3:
    line = l.rstrip()
    if line.startswith('##gff'):            # check gff-version
        gffFound = True
        gffNo = int(line[-1:])
        if gffNo == 3:
            note('GFF3-file is identified!')
        else:
            warning('This is the correct GFF3-version...')
            warning('Tread carefully!!!')
    if line.startswith('# This output'):    # check augustus-version
        versionNo = str(line[-7:-2])
        if versionNo == '3.0.1':
            note('Version of AUGUSTUS is correct!')
        else:
            warning('This is not output of AUGUSTUS (V3.0.1)...')
            warning('Tread carefully!!!')
    break
    #if line.startswith('# ----- prediction'):
if not gffFound:                            # warning if no gff-version found
    warning('No GFF3-version found... is this file corrupt?')
inputGFF3.close()
inputGFF3 = open(sys.argv[1],'r')
faname = str(str(basename) + str('.fa'))
fa = open(faname , 'w')

noPrediction_LengthList = []
Prediction_LengthList = []
AA_LengthList = []
for predictionBlock in group_by_heading( inputGFF3 ):
        heading= re.split(r' ', predictionBlock[0].rstrip())
        lines= predictionBlock[1:]
        proteinLineList = []
        handle = ''
        if (lines[2].rstrip() == '# (none)'):
            noPrediction_LengthList.append(int(heading[9].rstrip(',')))
            continue
        elif lines[2].rstrip().startswith('# start'):
            Prediction_LengthList.append(int(heading[9].rstrip(',')))
            handle = heading[12].rstrip(')')
        linecount = int(0)
        startline = int(0)
        endline = int(0)
        for line in lines:
            linecount += 1
            if line.rstrip().startswith('# protein sequence ='):
                regex = re.compile('[^A-Z]')
                prot = regex.sub('', line)
                proteinLineList.append(prot)
                startline = linecount
                if line.rstrip().endswith(']'):
                    endline = linecount
            elif line.rstrip().endswith(']'):
                endline = linecount
        regex = re.compile('[^A-Z]')
        protList = '_'.join(lines[startline-1:endline])
        prot = regex.sub('', protList)
        if len(prot) > 0:
            AA_LengthList.append(len(prot))
            fa.write('>' + handle + "\n" + prot.rstrip() + '\n')

# writing stats
nonCoding = numpy.array(noPrediction_LengthList)
Coding = numpy.array(Prediction_LengthList)
AA = numpy.array(AA_LengthList)
statname = str(str(basename) + str('.stats'))
st = open(statname , 'w')
st.write('ID\tvariable\tvalue\n')
st.write('Length protein-coding seqs\tN\t' + str(len(Coding))+ "\n")
st.write('Length protein-coding seqs\tMu\t' + str(numpy.mean(Coding, axis=0))+ "\n")
st.write('Length protein-coding seqs\tSigma\t' + str(numpy.std(Coding, axis=0))+ "\n")
st.write('Length non-coding seqs\tN\t' +  str(len(nonCoding))+ "\n")
st.write('Length non-coding seqs\tMu\t' + str(numpy.mean(nonCoding, axis=0))+ "\n")
st.write('Length non-coding seqs\tSigma\t' + str(numpy.std(nonCoding, axis=0))+ "\n")
st.write('Length protein-coding AA\tN\t' +  str(len(AA))+ "\n")
st.write('Length protein-coding AA\tMu\t' + str(numpy.mean(AA, axis=0)) + "\n")
st.write('Length protein-coding AA\tSigma\t' + str(numpy.std(AA, axis=0))+ "\n")
inputGFF3.close()
st.close()
fa.close()
