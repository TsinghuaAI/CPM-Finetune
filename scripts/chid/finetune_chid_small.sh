#!/bin/bash

DATA_DIR="/data/gyx/chid/preprocessed/"
CHECKPOINT_PATH="/mnt/nfs/home/gyx/CPM-distill/results/final"
RESULTS_DIR="results-local/"
MODEL_NAME="finetune-chid-small"
TOKENIZER_PATH="bpe_3w_new/"
MPSIZE=2
NLAYERS=12
NHIDDEN=768
NATT=12
MAXSEQLEN=1024

CUR_PATH=$(realpath $0)
CUR_DIR=$(dirname ${CUR_PATH})
DS_CONFIG="${CUR_DIR}/../ds_config/ds_finetune_small.json"

python3 -m torch.distributed.launch --master_port ${1-1122} --nproc_per_node 8 finetune_chid.py \
       --do_train \
       --do_eval \
       --data_dir ${DATA_DIR} \
       --model-parallel-size ${MPSIZE} \
       --num-layers ${NLAYERS} \
       --hidden-size ${NHIDDEN} \
       --load ${CHECKPOINT_PATH} \
       --num-attention-heads ${NATT} \
       --seq-length ${MAXSEQLEN} \
       --max-position-embeddings 1024 \
       --tokenizer-type GPT2BPETokenizer \
       --fp16 \
       --out-seq-length 512 \
       --tokenizer-path ${TOKENIZER_PATH} \
       --vocab-size 30000 \
       --lr 0.00001 \
       --warmup 0.1 \
       --batch-size 16 \
       --deepspeed \
       --deepspeed_config ${DS_CONFIG} \
       --log-interval 10 \
       --eval-interval 1000 \
       --seed 23333 \
       --results_dir ${RESULTS_DIR} \
       --model_name ${MODEL_NAME} \
       --epoch 10 \
       --checkpoint-activations \
       --deepspeed-activation-checkpointing