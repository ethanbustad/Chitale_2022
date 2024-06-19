#!/bin/sh
echo "Processing accession $1, allocated $2 cores and $3 memory"
echo "Working in dir: $4"
echo "Removing adapters using: $5"
echo "bowtie2 index prefix is: $6"
echo "Genome annotation file is: $7"
echo "featureCounts will use attribute: $8"
echo "Unique tag for this run is: $9"

module load java
module load Bowtie2
module load SAMtools
module load apptainer
module load biobuilds # fastqc
# module load sratoolkit # fasterq-dump
module load subread # featureCounts

function fasterq_dump() { # sratoolkit has handshake issues on Children's intranet; the container doesn't
	if [ ! -f ~/apptainer/sra-tools_3.0.0.sif ]
	then
		mkdir -p ~/apptainer
		apptainer pull --dir ~/apptainer/ docker://ncbi/sra-tools:3.0.0
	fi

	apptainer exec \
		--bind $PWD:/data \
		--pwd /data \
		~/apptainer/sra-tools_3.0.0.sif \
		fasterq-dump "$@"
}

exec_loc=$PWD

# enter the work directory
command="cd $4"
echo "$(date +"%Y-%m-%d %T") RUNNING $command"
$command

if [ ! -f $1_1.fastq ] | [ ! -f $1_2.fastq ]
then
	# download the accession
	command="fasterq_dump --threads $2 $1"
	echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
	$command
else
	echo "Skipping fasterq_dump command since fasta file is already present."
fi

# perform fastqc
command="fastqc -t $2 $1.fastq"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf *.html"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

if [ ! -f $1_1_c.fastq ] | [ ! -f $1_2_c.fastq ]
then
	# remove adapters
	command="/bin/sh $CONDA_PREFIX/opt/bbmap*/bbduk.sh in1=$1_1.fastq in2=$1_2.fastq out1=$1_1_c.fastq out2=$1_2_c.fastq ref=$5 ktrim=r k=23 mink=11 hdist=1 stats=$1.bbdukstats tpe tbo"
	echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
	$command
fi

if [ ! -f $1_1P.fastq ] | [ ! -f $1_1U.fastq ] | [ ! -f $1_2P.fastq ] | [ ! -f $1_2U.fastq ]
then
	# perform quality trimming using a sliding window of 4 bases, average q of 20
	command="trimmomatic PE -threads $2 $1_1_c.fastq $1_2_c.fastq $1_1P.fastq $1_1U.fastq $1_2P.fastq $1_2U.fastq SLIDINGWINDOW:4:20"
	echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
	$command >> $1.trimmomaticstats 2>&1
fi

# align reads to genome using bowtie2
command="bowtie2 --threads $2 -x $6 -U $1_ct.fastq -S $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command >> $1.bowtie2stats 2>&1

# convert sam to sorted bam for storage
command="samtools sort -o $1.bam $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
#$command

# assign alignments to features using featureCounts
command="featureCounts -T $2 -t $8 -g gene_id -a $7 -o $1_diff.counts.txt $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1.bam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1*.fastq"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command
