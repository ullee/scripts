#!/bin/bash

# 배포 경로
export HOME_DIR='/home/httpd'

# 여기에 브랜치 개행해서 여러개 추가 가능
export BRANCHES='
feature/TEST-001
bugfix/TEST-002
'

if [ -z "${HOME_DIR}" ]; then
  echo 'HOME_DIR is unset';
  exit;
fi

if [ -z "${BRANCHES}" ]; then
  echo 'BRANCHES is unset';
  exit;
fi

NC='\033[0m'

function INIT {
  cd ${HOME_DIR}
  git fetch --all --prune
  git checkout master
  git reset --hard origin/master
  git log -1
}
INIT

function MERGE {
  echo ""
  echo -e "\033[0;31mStart merge!! >> ${NC}"
  for i in $BRANCHES
  do
    echo -e "Branch is \033[0;33morigin/${i}${NC}"
    exists=`git show-ref refs/remotes/origin/${i}`
    if [ -n "${exists}" ]; then
      git merge origin/${i} -m "merge ${i}"
    else
      echo 'remote branch not found. please remove...'
    fi

    echo ""
  done
}
MERGE
