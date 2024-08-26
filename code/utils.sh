#!/usr/bin/env bash

function get_reverse_file () {
  local input_fwd_fastq=$1
  local input_rev_fastq=$(sed "s/$pattern_fwd/$pattern_rev/" <<< $input_fwd_fastq)

  input_rev_basename=$(basename $input_rev_fastq)
  
  input_rev_fastq=$(find -L ../data -name "$input_rev_basename")
  echo $input_rev_fastq
}

function get_index_file () {
  local input_fwd_fastq=$1
  local input_index_fastq=$(sed "s/$pattern_fwd/$pattern_index/" <<< $input_fwd_fastq)

  input_index_basename=$(basename $input_index_fastq)
  
  input_index_fastq=$(find -L ../data -name "$input_index_basename")
  echo $input_index_fastq
}