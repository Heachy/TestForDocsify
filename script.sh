#!/bin/bash

red='\e[91m'
green='\e[92m'
cyan='\e[96m'
none='\e[0m'

# -z是判断是否为空
if [[ -z $INPUT_MSG_A ]]; then
  echo -e "${red}ERROR: the INPUT_MSG_A field is required${none}" >&2
  exit 1
else
  echo -e "${cyan}Having input the INPUT_MSG_A: ${INPUT_MSG_A}"
fi

# -n是判断是否不为空
if [[ -n $INPUT_MSG_B ]]; then

  echo -e "${cyan}Having input the INPUT_MSG_B: ${INPUT_MSG_B}"
else
  echo -e "${red}ERROR: the INPUT_MSG_B field is required${none}" >&2
  exit 1
fi

