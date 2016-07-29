MAIL="thomas.magalhaes@curie.fr"

PBS_OUTPUT=/data/tmp/tmagalha/STDOUT
PBS_ERROR=/data/tmp/tmagalha/STDERR

VALGRIND_OUTPUT=/data/tmp/tmagalha/VALGRIND
#Path to pBWA binary


# PATHS CREATION
OUTPUT_DIR=/data/tmp/tmagalha/OUTPUT

# REFERENCE GENOME

#pSORT_BIN_DIR=/bioinfo/local/build/mpiSORT
pSORT_BIN_DIR=/bioinfo/users/tmagalha/Documents/Refactor_mpiSort
#pSORT_BIN_DIR=/bioinfo/users/fjarlier/Documents/workspace/parallelMergeSort_branch004/Debug
#pSORT_BIN_DIR=/bioinfo/users/fjarlier/Documents/workspace/test_mpiSort/mpiSORT
SAMPLENAME="MPISORT_REFACTOR_06_07_2016"
#BIN_NAME=parallelMergeSort_branch004
BIN_NAME=bin/psort
#160gb/file
#FILE_TO_SORT=/mnt/fhgfs/To_SORT/HCC1187C_10X.sam
#FILE_TO_SORT=/mnt/fhgfs/fjarlier/test_stripe/0.5G/HCC1187C_0.1X.sam
#FILE_TO_SORT=/mnt/fhgfs/fjarlier/test_stripe/0.5G/HCC1187C_0_01X.sam
FILE_TO_SORT=/mnt/fhgfs/fjarlier/test_stripe/0.5G/HCC1187C_1X.sam
#FILE_TO_SORT=/mnt/fhgfs/fjarlier/test_stripe/0.5G/HCC1187C_70K_READS.sam
#FILE_TO_SORT=/data/tmp/fjarlier/HCC1187C_70K_READS.sam
TOTAL_PROC=10

SAM_ALIGN_DIR="/mnt/fhgfs/fjarlier/OUTPUT_MPI"

DIR_TO_WRITE=/mnt/fhgfs/tmagalha2/OUTPUT

#jobname=`echo " mpirun -v -n $TOTAL_PROC valgrind --max-stackframe=4000000 --read-var-info=yes -q -v --tool=memcheck --track-origins=yes --leak-check=full --log-file=$VALGRIND_OUTPUT/valgrindout.dat $pSORT_BIN_DIR/psort $FILE_TO_SORT $DIR_TO_WRITE -q 0" | qsub -o $PBS_OUTPUT -e $PBS_ERROR -N ${SAMPLENAME} -q mpi  -l nodes=2:ppn=3,mem=200gb,walltime=01:00:00`

jobname=`echo " /bioinfo/local/build/openmpi/openmpi-1.8.3/bin/mpirun --mca btl self,sm,tcp --mca btl_base_verbose 30 -v -n $TOTAL_PROC $pSORT_BIN_DIR/$BIN_NAME $FILE_TO_SORT $DIR_TO_WRITE -q 0" | qsub -o $PBS_OUTPUT -e $PBS_ERROR -N ${SAMPLENAME} -q mpi  -l nodes=2:ppn=5,mem=100gb,walltime=01:00:00`

# to read the bam
# /bioinfo/local/build/samtools/samtools-1.2/bin/samtools view -h chr1.bam | less -S
# time /bioinfo/local/build/samtools/samtools-1.3/bin/./samtools view -Shb -@20 HCC1187C_5X.sam -o HCC1187C_5X.bam
#time /bioinfo/local/build/samtools/samtools-1.3/bin/./samtools sort -T /tmp/aln.sort -@20 HCC1187C_5X.bam -o HCC1187C_5X_sorted.bam
#sambamba sort --tmpdir $TMP_FOLDER -t 16 -o $OUTPUT_FILE $FILE_TO_SORT

jobname_id=${jobname%%.*}

k=1
JOB2WAIT[$k]="$PBS_OUTPUT/${SAMPLENAME}.o$jobname_id"
for j in "${!JOB2WAIT[@]}"
do 
    STATUS="running"

    if [ -e ${JOB2WAIT[$j]} ];then 

	 STATUS="done"
    else STATUS="running"
    fi
    while [ $STATUS != "done" ]
    do
	sleep 2
	if [ -e ${JOB2WAIT[$j]} ];then

	     STATUS="done"
	else STATUS="running"
	fi
    done
done

echo "we are done Aligning the files" 
#ERASE_FILE_PATH=/bioinfo/users/fjarlier/pbs_workdir/pBWA_pipeline
