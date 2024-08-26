#!/usr/bin/env bash

set -e

source ./config.sh
source ./utils.sh

input_fwd_fastqs=$(find -L ../data -name "*$pattern_fwd")

file_count=$(find -L ../data -name "*$pattern_fwd" | wc -l)

echo "Using threads: $num_threads"
echo "Input R1 Fastqs: $input_fwd_fastqs"

for input_fwd_fastq in $input_fwd_fastqs
do
  file_prefix=$(sed "s/$pattern_fwd//" <<< $input_fwd_fastq)
  file_prefix=$(basename $file_prefix)
  input_rev_fastq=$(get_reverse_file "$input_fwd_fastq")

  if [ -z $input_rev_fastq ]; then
    echo "Running in single end mode"
    read_files="$input_fwd_fastq"
  else
    if [ $reverse_input_reads == "True" ]; then
      echo "Reversing input reads" 
      read_files="$input_rev_fastq $input_fwd_fastq"
    else
      read_files="$input_fwd_fastq $input_rev_fastq"
    fi
  fi

  input_index_fastq=$(get_index_file "$input_fwd_fastq")

  #check for index read file, if not defined, we're in single end mode
  if [ -z $input_index_fastq ]; then # No index
    echo "No index fastq file"

    if [ $barcode_mate == "0" ]; then
      echo "Missing barcode fastq file! Cannot use Barcode Mate 0"
      exit 1
    fi

    read_files="$read_files"
  else
    read_files="$read_files $input_index_fastq"
  fi

  if [ "$shared_memory" = "True" ]; then
    genomeLoad="LoadAndKeep"
    extraArgs="--limitBAMsortRAM $limitBAMsortRAM"
  else
    genomeLoad="NoSharedMemory"
    extraArgs=""
  fi

  if [ "$two_pass" = "Per Sample" ]; then
    if [ "$shared_memory" = "True" ]; then
      echo "Running in two pass mode, will not use shared memory"
    fi
    genomeLoad="NoSharedMemory"
    twopassMode="Basic"
  else
    twopassMode="None"
  fi

  STAR --runThreadN "$num_threads" \
    --genomeDir "$genome_dir" \
    --readFilesIn $read_files \
    --readFilesCommand "$readFilesCommand" \
    --outFileNamePrefix "../results/${file_prefix}" \
    --outTmpDir "$outTmpDir" \
    --outSAMtype "BAM" $outSAMsort \
    --quantMode $quantMode \
    --outReadsUnmapped $outReadsUnmapped \
    --twopassMode $twopassMode \
    --chimOutType $chimOutType \
    --genomeLoad $genomeLoad \
    --soloType CB_UMI_Simple \
    --soloCBstart ${cb_start} \
    --soloCBlen ${cb_len} \
    --soloUMIstart ${UMI_start} \
    --soloUMIlen ${UMI_len} \
    --soloCBwhitelist ${white_list_file} \
    --soloCellFilter ${cell_filtering} \
    --soloFeatures ${quant_feature} \
    --soloMultiMappers ${multi_map} \
    --soloUMIdedup ${UMI_dedup} \
    --soloUMIfiltering ${UMI_filter} \
    --soloBarcodeReadLength ${barcode_read_len} \
    --soloBarcodeMate ${barcode_mate} \
    --clip5pNbases ${clip5pNbases} \
    --clip3pNbases ${clip3pNbases} \
    $extraArgs
done

if [ "$genomeLoad" = "LoadAndKeep" ]; then
  STAR --genomeDir "$genome_dir" --genomeLoad="Remove"
fi

if [ "$two_pass" = "Multi Sample" ]; then

  # Move previous splice junctions to folder.
  mkdir -p ../results/SpliceJunctionsFirstPass
  mv ../results/*SJ.out.tab ../results/SpliceJunctionsFirstPass

  # Rerun each sample
  for input_fwd_fastq in $input_fwd_fastqs
  do
    file_prefix=$(sed "s/$pattern_fwd//" <<< $input_fwd_fastq)
    file_prefix=$(basename $file_prefix)
    input_rev_fastq=$(get_reverse_file "$input_fwd_fastq")

    #check for R2, if not defined, we're in single end mode
    if [ -z $input_rev_fastq ]; then # we only have one read file
      echo "Running in single end mode"
      read_files="$input_fwd_fastq"
    else
      if [ $reverse_input_reads == "True" ]; then
        echo "Reversing input reads" 
        read_files="$input_rev_fastq $input_fwd_fastq"
      else
        read_files="$input_fwd_fastq $input_rev_fastq"
      fi
    fi

    input_index_fastq=$(get_index_file "$input_fwd_fastq")

    #check for index read file, if not defined, we're in single end mode
    if [ -z $input_index_fastq ]; then # we only have one read file
      echo "No index fastq file"

      if [ $barcode_mate == "0" ]; then
        echo "Missing barcode fastq file! Cannot use Barcode Mate 0"
        exit 1
      fi

      read_files="$read_files"
    else
      read_files="$read_files $input_index_fastq"
    fi

    # note: Some parameters are not in quotes because they can have more than one value (i.e, TranscriptomeSAM GeneCounts)
    # Shared memory is incompatible with two pass, so this needs to be not shared memory
    STAR --runThreadN "$num_threads" \
    --genomeDir "$genome_dir" \
    --readFilesIn $read_files \
    --readFilesCommand "$readFilesCommand" \
    --outFileNamePrefix "../results/${file_prefix}" \
    --outTmpDir "$outTmpDir" \
    --outSAMtype "BAM" $outSAMsort \
    --quantMode $quantMode \
    --outReadsUnmapped $outReadsUnmapped \
    --twopassMode "None" \
    --sjdbFileChrStartEnd ../results/SpliceJunctionsFirstPass/*SJ.out.tab \
    --chimOutType $chimOutType \
    --genomeLoad "NoSharedMemory" \
    --soloType CB_UMI_Simple \
    --soloCBstart ${cb_start} \
    --soloCBlen ${cb_len} \
    --soloUMIstart ${UMI_start} \
    --soloUMIlen ${UMI_len} \
    --soloCBwhitelist ${white_list_file} \
    --soloCellFilter ${cell_filtering} \
    --soloFeatures ${quant_feature} \
    --soloMultiMappers ${multi_map} \
    --soloUMIdedup ${UMI_dedup} \
    --soloUMIfiltering ${UMI_filter} \
    --soloBarcodeReadLength ${barcode_read_len} \
    --soloBarcodeMate ${barcode_mate} \
    --clip5pNbases ${clip5pNbases} \
    --clip3pNbases ${clip3pNbases} \
    $extraArgs
  done
fi

