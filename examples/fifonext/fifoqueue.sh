#!/bin/bash
if [[ $# -ne 3 ]]; then
  echo "Usage: ./fifoqueue <num-bits> <power> <start-id>"
  exit
fi

bw=$1
power=$2
((size = 2 ** power))

if [[ $3 = 1 ]]; then
  id=1
  echo "$((id++)) var 1 reset"
  ((idreset = id - 1))
  echo "$((id++)) var 1 enqeue"
  ((idenqueue = id - 1))
  echo "$((id++)) var 1 deqeue"
  ((iddequeue = id - 1))
  echo "$((id++)) var $bw data_in"
  ((iddatain = id - 1))
  echo "$((id++)) xor 1 $idenqueue $iddequeue"
  ((idxor = id - 1))
else
  id=$3
  #we skip inputs, as they have already been defined
  idreset=1
  idenqueue=2
  iddequeue=3
  iddatain=4
  idxor=5
fi

echo ""
echo "$((id++)) array $bw $power"
((idarray = id - 1))
echo "$((id++)) var 1 full_fq"
((idfull = id - 1))
echo "$((id++)) var 1 empty_fq" 
((idempty = id - 1))
echo "$((id++)) var $bw data_out_fq"
((iddataout = id  - 1))
echo "$((id++)) var $power head_fq"
((idhead = id - 1))
echo "$((id++)) var $power tail_fq"
((idtail = id - 1))

echo ""
((idzero = id))
((idone = id + 1))
for ((i = 0; i < size; i++))
do
  echo "$((id++)) constd $power $i"
done
((idmaxconst = id - 1))
((idmaxconstm1 = id - 2))

echo ""
echo "$((id++)) zero 1"
((idzero1 = id - 1))
echo "$((id++)) one 1"
((idone1 = id - 1))

echo ""
echo ";next of head_fq"
echo "$((id++)) add $power $idhead $idone"
((lastid = id - 1))
((idheadp1 = id - 1))
echo "$((id++)) cond $power $idempty $idhead $lastid" 
((lastid = id - 1))
echo "$((id++)) cond $power $iddequeue $lastid $idhead"
((lastid = id - 1))
echo "$((id++)) cond $power $idxor $lastid $idhead"
((lastid = id - 1))
echo "$((id++)) cond $power $idreset $lastid $idzero"
((lastid = id - 1))
echo "$((id++)) next $power $idhead $lastid" 

echo ""
echo ";next of tail_fq"
echo "$((id++)) add $power $idtail $idone"
((lastid = id - 1))
((idtailp1 = id - 1))
echo "$((id++)) cond $power $idfull $idtail $lastid" 
((lastid = id - 1))
echo "$((id++)) cond $power $idenqueue $lastid $idtail"
((lastid = id - 1))
echo "$((id++)) cond $power $idxor $lastid $idtail"
((lastid = id - 1))
echo "$((id++)) cond $power $idreset $lastid $idzero"
((lastid = id - 1))
echo "$((id++)) next $power $idtail $lastid" 

echo ""
echo ";next of full_fq"
echo "$((id++)) add $power $idtailp1 $idone"
((lastid = id - 1))
echo "$((id++)) eq 1 $lastid $idhead"
((lastid = id - 1))
echo "$((id++)) cond 1 $lastid $idone1 $idfull"
((lastid = id - 1))
echo "$((id++)) cond 1 $iddequeue $idzero1 $lastid"
((lastid = id - 1))
echo "$((id++)) cond 1 $idxor $lastid $idfull"
((lastid = id - 1))
echo "$((id++)) cond 1 $idreset $lastid $idzero1"
((lastid = id - 1))
echo "$((id++)) next 1 $idfull $lastid"


echo ""
echo ";next of empty_fq"
echo "$((id++)) eq 1 $idheadp1 $idtail"
((lastid = id - 1))
echo "$((id++)) cond 1 $lastid $idone1 $idempty"
((lastid = id - 1))
echo "$((id++)) cond 1 $idenqueue $idzero1 $lastid"
((lastid = id - 1))
echo "$((id++)) cond 1 $idxor $lastid $idempty"
((lastid = id - 1))
echo "$((id++)) cond 1 $idreset $lastid $idone1"
((lastid = id - 1))
echo "$((id++)) next 1 $idempty $lastid"

echo ""
echo ";next of data_out_fq"
echo "$((id++)) read $bw $idarray $idhead"
((idread = id - 1))
echo "$((id++)) and 1 $iddequeue -$idempty"
((lastid = id - 1))
echo "$((id++)) cond $bw $lastid $idread $iddataout"
((lastid = id - 1))
echo "$((id++)) cond $bw $idxor $lastid $iddataout"
((lastid = id - 1))
echo "$((id++)) cond $bw $idreset $lastid $iddataout"
((lastid = id - 1))
echo "$((id++)) next $bw $iddataout $lastid"

echo ""
echo ";next of queue memory"
echo "$((id++)) write $bw $power $idarray $idtail $iddatain"
((lastid = id - 1))
echo "$((id++)) acond $bw $power $idfull $idarray $lastid"
((lastid = id - 1))
echo "$((id++)) acond $bw $power $idenqueue $lastid $idarray"
((lastid = id - 1))
echo "$((id++)) acond $bw $power $idxor $lastid $idarray"
((lastid = id - 1))
echo "$((id++)) acond $bw $power $idreset $lastid $idarray"
((lastid = id - 1))
echo "$((id++)) anext $bw $power $idarray $lastid"