# STAR-Solo Single Cell Alignment

Fast alignment of sc-RNAseq (single cell RNAseq) data to DNA references with or without known splice junctions. See [STAR Manual](https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md) for more details.

- **Please be advised this capsule is running SoloType - CB_UMI_Simple!**
- **Please be advised, you should merge lanes prior to using this tool!**

## Input data

Fastq Files
- In **data** directory, any fastq files. These files can be compressed in gz format. Please take note this format can effect parameter 6. 

STAR Genome Directory
- the directory containing the STAR index required for alignment. Must be preprocessed using STAR index tool. See documentation for more details.

Whitelist
- the whitelist corresponding to the version of 10x genomics technology utilized. 

## App Panel Parameters

### Main Parameters

Threads
- Number of threads
- Default is all available threads. 
- If you request more threads than available. The parameter is set to Default - All Available Threads.

STAR Genome Directory
- STAR genome. 
- Must be preprocessed using STAR index tool. See STAR Index capsule in the Apps Library for more details.

Pattern Forward
- Pattern for forward sequence in paired end reads.
- i.e., sample_S1_L001_R1_001.fastq.gz would be "_R1_001.fastq.gz". 

Pattern Reverse
- Pattern for reverse sequence of reads. 
- i.e., sample_S1_L001_R1_001.fastq.gz would be "_R1_001.fastq.gz".

UMI Read Suffix
- Pattern for the UMI sequence of reads.
- i.e., sample_S1_L001_R3_001.fastq.gz would be "_R3_001.fastq.gz".

Read files command
- Unzip command to read fastq files.
- You may pass gzipped fastq files but adjust Read Files Command, accordingly.  
- Default is Zcat

### Auxiliary Parameters

Sort Type 
- **Unsorted** outputs unsorted files (these can be processed downstream by software expecting name sorted reads such as HTseq) 
- **SortedByCoordinate** outputs sorted and indexed .bams. (Default)
- **Unsorted SortedByCoordinate** outputs both unsorted and sorted .bams. 

Quant Mode
- **TranscriptomeSAM** output alignments translated into transcript coordinates in the Aligned.toTranscriptome.out.bam file. see [STAR Manual](https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf) for more details.
- **GeneCounts** STAR will count number reads per gene while mapping
- **TranscriptomeSAM GeneCounts** Output both

Output Unmapped Reads
- **Within** will output to .bam file
- **Within KeepPairs** will (redundantly) record unmapped mate
for each alignment, and, in case of unsorted output, keep it adjacent to its mapped mate (this only
affects multi-mapping reads).
- **FastX** will output unmapped reads into Unmapped.out.mate1.
- Default is None

Chimeric output (for fusion calling)
- **Junctions**: Chimeric.out.junction
- **SeparateSAMold**: output old SAM into separate Chimeric.out.sam file
- **WithinBAM HardClip**: hard clip supplemental chimeric alignments. (Default)
- **WithinBAM SoftClip**: soft clip supplemental chimeric alignments

Two pass alignment 
- **Per sample**: STAR will perform the 1st pass mapping, then it will automatically extract junctions, insert them into the genome index, and, finally, re-map all reads in the 2nd mapping pass
- **Multi-sample**: STAR will perform 1st pass mapping on ALL samples. On the second pass, STAR will include .SJ.out.tab files for all previous samples
- **None**: STAR will only perform 1st pass mapping. (Default)

*Note*: Multi-sample may be more suited for a Pipeline since the first pass can run in a separate instance for each sample, then be followed by a collection step for the junction outputs and then the second pass can also run on separate instances. 

In general, for larger samples, it may be better to run in a pipeline since each sample can use its own instance. 

Shared Memory
- Determines whether samples share the same genome in RAM or reload the genome each time. This is incompatible with Per Sample two pass and the second pass for multi sample two pass. Generally, this is preferred for small samples (~3 million reads) since there is overhead each time the genome is loaded. [default: False]

RAM reserved for BAM sort (GB)
- Only used with shared memory. Determines the amount of RAM to reserve for bam sorting. Should be at least 10. [default: 10]

Cell Filtering 
- **soloCellFilter**: The cell calling step aims to filter out the CBs that correspond to empty droplets, i.e. contain ambient RNA rather than true cells. Multiple methods have been developed to perform the cell filtering, and these tools can be directly applied to the raw count matrix generated by STARsolo. [default: CellRanger2.2]
- CellRanger2.2: simple filtering of CellRanger 2.2. 
- EmptyDrops_CR: EmptyDrops filtering in CellRanger flavor. Please cite the original EmptyDrops paper: A.T.L Lun et al, Genome Biology, 20, 63 (2019): https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1662-y
- TopCells: Only report top cells by UMI count, followed by the exact number of cells
- None: Do not output filtered cells

Quantify Features
- **soloFeatures**: Quantification of transcriptomic Features [default: Gene]
- Gene
    - Will count Gene Counts, only.
- GeneFull
    - pre-mRNA counts, useful for single-nucleus RNA-seq. This counts all read that overlap gene loci, i.e. included both exonic and intronic reads.
- SJ 
    - Counts for annotated and novel splice junctions. 
- GeneFull_ExonOverIntron GeneFull_Ex50pAS
  - Prioritize exonic over intronic overlaps for pre-mRNA counting.

Multi Mapping Genes 
- **soloMultiMappers**: Techniques for quantifying reads mapping to multiple regions of the genome. [default: Unique]

UMI Deduplication
- **soloUMIdedup**: Techniques for performing Deduplication of UMI's. [default: 1MM_CR]
- 1MM_CR
    - all UMIs with 1 mismatch distance to each other are collapsed (i.e. counted once).
- 1MM_Directional_UMItools
    - follows the "directional" method from the UMI-tools bySmith, Heger and Sudbery (Genome Research 2017).
- 1MM_Directional
    - same as 1MM_Directional_UMItools, but with more stringent criteria for duplicate UMIs
- Exact
    - only exactly matching UMIs are collapsed.
- NoDedup
    - no deduplication of UMIs, count all reads.
- 1MM_CR
    - CellRanger2-4 algorithm for 1MM UMI collapsing.

UMI Filtering
- **soloUMIfiltering**: Techniques for determining when UMI's map to multiple genes. [default: MultiGeneUMI_CR]
- MultiGeneUMI_CR
    - basic + remove lower-count UMIs that map to more than one gene,matching CellRanger > 3.0.0.
    - Only works with UMI Deduplication 1MM_CR
- MultiGeneUMI
    - basic + remove lower-count UMIs that map to more than one gene.
- MultiGeneUMI_All
    - basic + remove all UMIs that map to more than one gene.

Whitelist
- **soloCBwhitelist**: A .txt file encoding barcodes attached to UMI's with respect to chemistry used during library preparation. [default: None]
- Add your path to the file.

CB Start Position 
- **soloCBstart**: The start site of your cellular barcode. [default: 1]

CB Length
- **soloCBlen**: The length of your cellular barcode. [default: 16]

UMI Start Position
- **soloUMIstart**: The start site of your Unique Molecular Identifier [default: 17]

UMI Length
- **soloUMIlen**: The length of your Unique Molecular Identifier. [default: 10]

Barcode Mate 
- **soloBarcodeMate**: identifies which read mate contains the barcode (CB+UMI) sequence [default: 0]
- 0 
    - barcode sequence is on separate read, which should always be the last file in the --readFilesIn listed
- 1 
    - barcode sequence is a part of mate 1
- 2
    - barcode sequence is a part of mate 2

Barcode Read Length
- **soloBarcodeReadLength**: Length of the barcode read [default: 0]
- 1 : equal to sum of soloCBlen+soloUMIlen
- 0 : not defined, do not check.

Clip 5" bases
- **clip5pNbases**: Number(s) of bases to clip from 5p of each mate. If one value is given, it will be assumed the same for both mates. [default: 0]

Clip 3" bases
- **clip3pNbases**: Number(s) of bases to clip from 3p of each mate. If one value is given, it will be assumed the same for both mates. [default: 0]

## Outputs

These can vary depending on output parameters, but by default: 

**Aligned.sortedByCoord.out.bam**: Output alignments

**Log.final.out, Log.out, Log.progress.out**: Logs generated by STAR. Log.out contains parameter defaults and which parameters are overwritten. 

**SJ.out.tab**: Splice junctions. Format is specified in [STAR Manual](https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf).

**Solo.out** : A folder containing raw counts matrices (and filtered, if selected on the App Panel) with their associated statistics. 

## Source

https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md
https://software.cqls.oregonstate.edu/updates/star-2.7.10a/index.md
