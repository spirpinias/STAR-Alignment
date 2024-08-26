#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
else
  echo "args:"
  for i in $*; do 
    echo $i 
  done
  echo ""
fi

some_fastq=$(find -L ../data -name "*.f*q*" | head -1)
echo "some_fastq: $some_fastq"

outTmpDir="../scratch/temp"

# STAR
if [ -z "${1}" ]; then
  num_threads=$(get_cpu_count)
else
  if [ "${1}" -gt $(get_cpu_count) ]; then
    echo "Requesting more threads than available. Setting to Max Available."
    num_threads=$(get_cpu_count)
  else
    num_threads="${1}"
  fi
fi

if [ -z "${2}" ]; then
  genome_file=$(find -L ../data -name "SAindex")
  genome_dir=$(dirname "${genome_file}")
else
  genome_dir="${2}"
fi 

if [ -z "${3}" ]; then
  pattern_fwd="_$(get_read_pattern "$some_fastq" --fwd)"
else
  pattern_fwd="${3}"
fi

if [ -z "${4}" ]; then
  pattern_rev="_$(get_read_pattern "$some_fastq" --rev)"
else
  pattern_rev="${4}"
fi

if [ -z "${5}" ]; then
  pattern_index="no_index_file"
else
  pattern_index="${5}"
fi

if [ -z "${6}" ]; then
  reverse_input_reads="False"
else
  reverse_input_reads="${6}"
fi

# STAR Alignment Parameters

if [ -z "${7}" ]; then
  readFilesCommand="zcat"
else
  readFilesCommand="${7}"
fi

if [ -z "${8}" ]; then
  outSAMsort="SortedByCoordinate"
else
  outSAMsort="${8}"
fi

if [ -z "${9}" ]; then
  quantMode="-"
else
  quantMode="${9}"
fi

if [ -z "${10}" ]; then
  outReadsUnmapped="None"
else
  outReadsUnmapped="${10}"
fi

if [ -z "${11}" ]; then
  chimOutType="WithinBAM HardClip"  # For some reason the documentation lists Junctions as the default, but it totally isn't anymore.
else
  chimOutType="${11}"
fi

if [ -z "${12}" ]; then
  two_pass="None"
else
  two_pass="${12}"
fi

if [ -z "${13}" ]; then
  shared_memory="False"
else
  shared_memory="${13}"
fi

if [ -z "${14}" ]; then
  limitBAMsortRAM=10000000000
else
  limitBAMsortRAM=$((${14} * 1000000000))
fi

if [ -z "${15}" ]; then
  cell_filtering="CellRanger2.2"
else
  cell_filtering="${15}"
fi

if [ -z "${16}" ]; then
  quant_feature="Gene"
else
  quant_feature="${16}"
fi

if [ -z "${17}" ]; then
  multi_map="Unique"
else
  multi_map="${17}"
fi

if [ -z "${18}" ]; then
  UMI_dedup="1MM_All"
else
  UMI_dedup="${18}"
fi

if [ -z "${19}" ]; then
  UMI_filter="-"
else
  UMI_filter="${19}"
fi

if [ -z "${20}" ]; then
    white_list=""
    white_list_count=0
    white_list_file="None"
else
    white_list_count=1
    white_list_file="${20}"
fi

if [ -z "${21}" ]; then
    cb_start="1"
else
    cb_start="${21}"
fi

if [ -z "${22}" ]; then
    cb_len="16"
else
    cb_len="${22}"
fi

if [ -z "${23}" ]; then
    UMI_start="17"
else
    UMI_start="${23}"
fi

if [ -z "${24}" ]; then
    UMI_len="10"
else
    UMI_len="${24}"
fi

if [ -z "${25}" ]; then
    barcode_mate="1"
else
    barcode_mate="${25}"
fi

if [ -z "${26}" ]; then
    barcode_read_len="1"
else
    barcode_read_len="${26}"
fi


if [ -z "${27}" ]; then
    clip5pNbases="0"
else
    clip5pNbases="${27}"
fi


if [ -z "${28}" ]; then
    clip3pNbases="0"
else
    clip3pNbases="${28}"
fi