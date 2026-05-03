#!/bin/bash

allowed_args=("ONECYCLE" "TWOCYCLE" "FOURCYCLE" "TWOSTAGE" "TWOSTAGEBTB")

log_suffix="$1"

# 检查是否输入参数
if [ -z "$log_suffix" ]; then
    echo "错误：请输入一个参数！"
    echo "允许的值：${allowed_args[*]}"
    exit 1
fi

# 检查参数是否合法
valid=0
for a in "${allowed_args[@]}"; do
    if [ "$a" = "$log_suffix" ]; then
        valid=1
        break
    fi
done

if [ $valid -eq 0 ]; then
    echo "错误：输入参数不合法！"
    echo "允许的值：${allowed_args[*]}"
    exit 1
fi

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
log_dir="logs-${log_suffix}"
wait_time=3
count=0

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
