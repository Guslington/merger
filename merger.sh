#!/bin/bash
set -e

## Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;93m'
NC='\033[0m'

function waiting()
{
  case $toggle
  in
    1)
      echo -n $1" . "
      echo -ne "\r"
      toggle="2"
    ;;

    2)
      echo -n $1" .. "
      echo -ne "\r"
      toggle="3"
    ;;

    3)
      echo -n $1" ... "
      echo -ne "\r"
      toggle="4"
    ;;

    *)
      echo -ne $1"     \r"
      toggle="1"
    ;;
  esac
}

if [ -z "$1" ]
  then
    echo -e "${RED}Please submit a comment...${NC}"
    exit 1
fi

COMMENT=$1
BRANCH=develop

git add *
git commit -m "${COMMENT}"
git pull --rebase upstream ${BRANCH}
git push origin ${BRANCH}
PULL=$(hub pull-request -m "${COMMENT}" upstream ${BRANCH} | rev | cut -d '/' -f1 | rev)
echo -e "${GREEN}Pull request: ${PULL}${NC}"
ghi show ${PULL}

end=$((SECONDS+60))
echo -e ${YELLOW}
while [ $SECONDS -lt $end ]; do
  waiting "Waiting for jenkins"
  sleep 0.3
done
echo -e "${NC}"

while :
do
  ghi show ${PULL}
  echo -e "${RED}What would you like to do?${NC}"
  read -p "[M]erge | [R]etest | [F]ix | [C]lose | [O]pen in browser: " choice
  case "$choice" in
    m|M )
      echo -e "${GREEN}Merging...${NC}"
      ghi comment -m 'ok to merge' ${PULL}
      break
      ;;
    r|R )
      echo -e "${GREEN}Retesting...${NC}"
      ghi comment -m 'retest this please' ${PULL}
      ghi show ${PULL}
      end=$((SECONDS+45))
      echo -e ${YELLOW}
      while [ $SECONDS -lt $end ]; do
        waiting "Waiting for jenkins"
        sleep 0.3
      done
      echo -e "${NC}"
      ;;
    c|C )
      echo -e "${GREEN}Closing...${NC}"
      ghi close ${PULL}
      break
      ;;
    f|F )
      CHANAGES=$(git diff-index --name-only HEAD)
      if [[ -n $CHANAGES ]]; then
        echo -e "${GREEN}Applying changes to...${NC}"
        git diff-index --name-only HEAD
        git add *
        git commit -m "${COMMENT}"
        git pull --rebase upstream ${BRANCH}
        git push origin ${BRANCH}
      fi
      echo -e "${RED}No changes to apply...${NC}"
      ;;
    o|O )
      echo -e "${GREEN}Opening pull request in browser...${NC}"
      ghi show -w ${PULL}
      echo -e "${GREEN}Exiting...${NC}"
      exit  0
      ;;
    * ) echo -e "${RED}invalid...${NC}";;
  esac
done
ghi show ${PULL}
end=$((SECONDS+45))
echo -e ${YELLOW}
while [ $SECONDS -lt $end ]; do
  waiting "Waiting for jenkins"
  sleep 0.3
done
echo -e "${NC}"
ghi show ${PULL}
echo -e "${GREEN}done ${YELLOW}:D ${GREEN}have a lovely day!!${NC}"
