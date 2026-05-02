#!/bin/bash


asm_tests=(
	simple
	add addi
	and andi
	auipc
	beq bge bgeu blt bltu bne
	j jal jalr
	lw
	lui
	or ori
	sw
	sll slli
	slt slti
	sra srai
	srl srli
	sub
	xor xori
	bpred_bht bpred_j bpred_ras
	cache
	)

vmh_dir=programs/build/assembly/vmh
log_dir=logs-asm
wait_time=3

# create bsim log dir
mkdir -p ${log_dir}

# kill previous bsim if any
pkill bluetcl

# run each test
for test_name in ${asm_tests[@]}; do
	prefix=$(printf "%02d" $count)
	echo "-- assembly test: ${test_name} --"
	# copy vmh file
	mem_file=${vmh_dir}/${test_name}.riscv.vmh
	target="bluesim/mem.vmh"
	if [ ! -f $mem_file ]; then
		echo "ERROR: $mem_file does not exit, you need to first compile"
		exit
	fi
	# set -x
	cp ${mem_file} ${target}
	
	# run test
	make run.bluesim > ${log_dir}/${prefix}_${test_name}.log # run bsim, redirect outputs to log
	# set +x
	# sleep ${wait_time}
	# echo "${test_name} over"
	count=$((count + 1))
	echo ""
done
