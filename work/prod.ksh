VERSION=2020-04-27
echo Version: ${VERSION}

set +x

# Make sure we have a writeable home
VOTD=idesktop20.heathrow.ms.com
PRODHOME=/var/tmp/${USER}
export v=${PRODHOME}
if [[ ! -e ${PRODHOME} && ${HOSTNAME} != ${VOTD} ]]; then
    
    mkdir ${PRODHOME}
    echo "Setting PRODHOME to ${PRODHOME}"
    cd ${PRODHOME}

fi

if [[ -e ${HOME}/prod || -e ${HOME}/basic ]]; then

    echo "###"
    echo "### Profile found in ${HOME}"
    echo "###"

fi


# Do we have a ~/.vimrc
if [[ ! -e ~/.vimrc ]]; then
    /usr/bin/curl -s http://myweb/~piried/.vimrc -o ~/.vimrc
fi

##################################################################################
# Some proids don't load MS environ file automatically, for example msdeprod on ny02ilas01

MODULES_ENABLED=$(which modulecmd 2> /dev/null > /dev/null)

if [[ $? -gt 0 ]]; then

    NEED_ETC=true
    ENVIRON_RELEASE=prod
    unset _KSH_FUNCS  # Required for Virtual Machines, makes Kuu'ing not run environment

    . /ms/dist/environ/PROJ/core/$ENVIRON_RELEASE/common/etc/init.environ

fi

# Add Custom Modules
MODULEPATH=$HOME/.custom/modules:${MODULEPATH}

##################################################################################
### Create working folders

# Store history
if [[ ! -d ~/history ]]; then
    mkdir ~/history
fi
export HISTFILE=~/history/ksh.${USER}.$(date +%Y%m%d).$$

# Set Compile Share
export CS=/v/campus/ln/cs/msde/piried

# Set P4 Vars
export P4READ=/v/region/na/appl/msde/p4read/data/prod
export P4SU=/v/region/na/appl/msde/p4su/data/prod
export P4EDITOR=vim

# Set Up TMUX
# export TMUX_BIN=/ms/dist/fsf/PROJ/tmux/2.5/bin/tmux
export TMUX_BIN=/ms/dist/fsf/PROJ/tmux/2.8/bin/tmux
alias tmux="${TMUX_BIN} -2"
export MANPATH=${MANPATH}:/ms/dist/fsf/PROJ/tmux/2.8/common/share/man

# # TMUX session windows only
# if [[ ! -z ${TMUX_PANE} ]]; then
#     set -o ignoreeof
# fi

# Prevent all windows from exiting shell using ctrl+d
set -o ignoreeof

# RHEL7 Check. 1 = RHEL7 detected
! grep -q 'aquilon/linux/7.1-x86_64' /etc/motd
export RHEL7=$?
echo "RHEL7=${RHEL7}"

# Set $YYYYMMDD
export YYYY=$(date +%Y)
export MM=$(date +%m)
export DD=$(date +%d)
export YYYYMMDD=${YYYY}${MM}${DD}


# Set History and some action shortcuts
alias h='history'
alias hh='history 0'
alias H='history'
alias HH='history 0'
alias cp='cp -ipv'
alias mv='mv -iv'
alias rm='rm -iv'

# Defaults
if [[ `set -o | grep -c multiline` -gt 0 ]]; then set -o multiline 2> /dev/null; fi

set -o histexpand

# Set vim / emacs editing
export EDITOR=vim
set +o vi
set -o emacs


##################################################################################
### Check Tokens

# Ask for tokens
/ms/dist/afs/bin/tokens | grep Expires > /dev/null 2> /dev/null || /ms/dist/aurora/bin/ak5log > /dev/null 2> /dev/null || kinit

# Repeat until we get them tokens
while [[ $? -gt 0 ]]; do
    /ms/dist/afs/bin/tokens | grep Expires > /dev/null 2> /dev/null || /ms/dist/aurora/bin/ak5log > /dev/null 2> /dev/null || kinit
done


# Lets check they are valid till after friday
# The tokens script only gives month and day, this routine fails if we are in the week before nexy year
TOKEN_DATE=$(date +%Y%m%d -d $(tokens | awk '{ if($9!="" && $10!="") print $9$10 }' | sort -ur | head -n1))
FRI_DATE=$(date +%Y%m%d -d Fri)

if [[ ${TOKEN_DATE} -gt ${FRI_DATE} ]]; then

    echo "Tokens valid until "$(date -d ${TOKEN_DATE} +%A\ %d,\ %B\ %Y)

else

    echo "Tokens only valid until "$(date -d ${TOKEN_DATE} +%A\ %d,\ %B\ %Y)", forcing kinit"
    echo "Need tokens to ${FRI_DATE}"
    kinit

fi


##################################################################################
### Set Environment Default variables
export PAGER=less


##################################################################################
### Load modules

if [[ ! -e ~piried/etc/.nomodules ]]; then

    echo "Loading modules"

    module load astro
    module load aquilon
#     module load aurora/dsdb
    module load cloud/treadmill/3
    module load dbau/dbap 2> /dev/null	
#     module load ecm/tcm2cli/qa
#     module load fsf/autocutsel
#     module load fsf/coreutils/8.24 || echo 007
#     module load fsf/findutils/4.4.2
#     module load fsf/gnuemacs/prod || echo 006
#     module load fsf/mutt || echo 004
    # module load fsf/vim/7.4.70 # Out of date
    export PATH=/ms/dist/fsf/PROJ/vim/8.1.0290-0/bin:${PATH}
#     module load laas/getlogs/prod
    module load laf/hlm/prod
    module load laf/host_reboot
    module load laf/hostref
    module load laf/lb/prod
    module load laf/logwatch
    module load laf/webauth
    module load laf/z/prod
    module load msde/git/2.16.2 > /dev/null 2> /dev/null
    module load msde/traincli/prod
    module load msjava/scripts/settz
    module load mssql/sqlassist
    module load perl5/core/5.20
    module load python/core/3.4.4
    module load sam/zappcfg/prod
    module load sec/openssh/prod
    module load sec/ssq
    module load storage
    module load storage/laf-nas
    module load syb/kerberos
    module load tai/cli 2> /dev/null
    module load vcs
#     module load virtual/spot
#     module load webinfra
    module load webinfra/kuula/3.x-prod
    module load zappctrl
    module load appmw/zssh/prod
    module load laf/msvcs
    module load laf/aquilon

    # set +x

fi

### Variables 
export MANPAGER="less -I -S"


### Set Proxies
export ftp_proxy=http://wwwproxy.ms.com:8080
export http_proxy=http://wwwproxy.ms.com:8080
export https_proxy=http://wwwproxy.ms.com:8080

##################################################################################
### Set custom colours

export MY_DIRCOLORS=~piried/etc/dir_colors
if [[ -e ${MY_DIRCOLORS} ]]; then
    eval `dircolors ${MY_DIRCOLORS}` # Load David's Custom Colours for ls
else
    echo "Error: could not load ${MY_DIRCOLORS}"
fi

alias l='ls -lArthH --color=always'

# Grep to Highlight matched 
alias grepc='grep --color=always'

# Set Grep Highlight
export GREP_COLOR='1;33;41'

###
##################################################################################


# Turn off the really annoying CTRL+S freeze terminal
stty ixany
stty ixoff -ixon

# Lets be sneaky and turn off any timeouts :)
unset TMOUT

#export TERM=xterm-256color # Resizes Putty in Screen
#export TERM=xterm-color # Resizes Putty in Screen
export TERMINFO=/ms/dist/fsf/PROJ/ncurses/5.9/common/gcc44_64/share/terminfo
export TERM=xterm
#export TERM=putty-256color
export TERMCAP=/etc/termcap
export SHELL=ksh
export LINES=140
export COLUMNS=512


##################################################################################
### Functions

# Set exit strategy, 2 = CTRL+C
# trap cleanup 1 2 3 6
trap cleanup 0

function cleanup {

    # Use ~ first
    echo CleanUp

}

function p4reboots {

    module load astro
    FROM=$(date +%m/01/%Y -d '1 month ago')
    TO=$(date +%m/01/%Y -d '1 months')o

    for P4HOST in rr850c1n5 hz850c1n5 rr851c1n1 hz851c1n1; do
        astro predict_reboot -host ${P4HOST} -from ${FROM} -to ${TO}
    done

}

function reboot_info {

    for F in /var/log/wtmp*
    do 
        last -x reboot shutdown runlevel -f $F
    done

}

function mscurl {

    URL=$1
    FILENAME=$(basename ${URL})

#     /ms/dist/fsf/PROJ/curl/7.60.0-0/bin/curl -L --negotiate -u: -k -J $URL -o $FILENAME
    /usr/bin/curl -L --negotiate -u: -k -J $URL 

}

function mdy {

    # Convert MM/DD/YY into YY/MM/DD
    # Convert MM-DD-YY into YY/MM/DD

    if [[ ! -t 0 ]]; then
        INPUT=$(cat)
    else
        INPUT=$*
    fi

    echo "${INPUT}" | sed -r 's/([0-9]{2})\/([0-9]{2})\/([0-9]{2})/\3\/\1\/\2/g' | sed -r 's/([0-9]{2})\-([0-9]{2})\-([0-9]{2})/\3\/\1\/\2/g'

}

function warn {

    echo -e '\a'

}

function roles {

    ROLEUSER=${1:-${USER}}
    echo "Roles for ${ROLEUSER}"
    
    if [[ -z ${2} ]]; then
        tap --myroles --user ${ROLEUSER} | \grep -Eo "grn:[^ ]*" | sort -i
    else
        tap --myroles --user ${ROLEUSER}
    fi

}

function j {

    for JOB in $*
    do

        autorep -wj ${JOB}

    done


}

function jdiff {

    JOB=$1

    print "Job : ${JOB}"

    J=$( autorep -j ${JOB} | grep ${JOB} )
    if [[ $? > 0 ]]; then
        exit 1
    fi

    FROM=$(echo ${J} | awk {' print $2" "$3 '})
    TO=$(echo ${J} | awk {' print $4" "$5 '})

    print "From: ${FROM}"
    print "To  : ${TO}"

    FROM_SECS=$( date -d"${FROM}" +%s )
    TO_SECS=$( date -d"${TO}" +%s )
    DIFF=$(( ${TO_SECS} - ${FROM_SECS} ))

    echo "Secs: ${DIFF}"
    printf 'Time: %dd %dh:%dm:%ds\n' $(($DIFF/86400)) $(($DIFF%86400/3600)) $(($DIFF%3600/60)) $(($DIFF%60))


}

function tdiff {

    FROM=$1
    TO=$2

    print "From: ${FROM}"
    print "To  : ${TO}"

    FROM_SECS=$( date -d"${FROM}" +%s )
    TO_SECS=$( date -d"${TO}" +%s )
    DIFF=$(( ${TO_SECS} - ${FROM_SECS} ))

    echo "Secs: ${DIFF}"
    printf 'Time: %dd %dh:%dm:%ds\n' $(($DIFF/86400)) $(($DIFF%86400/3600)) $(($DIFF%3600/60)) $(($DIFF%60))


}

function secs {

    secs=$1
    printf '%dd %dh:%dm:%ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60))

}

function age {

    dt=$1
    dt_secs=$(date -d "$dt" +%s -u)
    now_secs=$(date +%s -u)
    diff=$(( ${now_secs} - ${dt_secs} ))

    printf '%dd %dh:%dm:%ds\n' $(($diff/86400)) $(($diff%86400/3600)) $(($diff%3600/60)) $(($diff%60))

}

function hours {

    hours=$1
    printf '%dd %dh\n' $(($hours/24)) $(($hours%24))

}

function sdiff {

    FILE1=$1
    FILE2=$2

    if [[ -z $3 ]]; then
        WIDTH=$( stty size | awk '{ print $2 }' )
    else
        WIDTH=$3
    fi

#     echo "diff <( sort ${FILE1} ) <( sort ${FILE2} ) -y -W ${WIDTH} --suppress-common-lines"
    diff <( sort ${FILE1} ) <( sort ${FILE2} ) -y -W ${WIDTH} --suppress-common-lines

}

function upt {

    # Show date and time host was started
    STARTED=$(cut -f1 -d\  /proc/uptime)

    print ""
    print "Host Started"
    print "============"
    date -d "${STARTED} seconds ago"
    date -u -d "${STARTED} seconds ago"
    TZ=Europe/London date -d "${STARTED} seconds ago"
    print ""

    # Show uptime stats
    print "Uptime"
    print "======"
    uptime
    print ""

}

function turnover {

    TURNOVER_FILE=~piried/etc/turnover.txt
    if [[ -e ${TURNOVER_FILE} ]]; then

        if [[ -z ${META} ]]; then; META=\$META; fi
        if [[ -z ${PROJ} ]]; then; PROJ=\$PROJ; fi
        if [[ -z ${RELEASE} ]]; then; RELEASE=\$RELEASE; fi
        if [[ -z ${OLD_RELEASE} ]]; then; OLD_RELEASE=\$OLD_RELEASE; fi
        if [[ -z ${LINK} ]]; then; LINK=\$LINK; fi
        if [[ -z ${TCM} ]]; then; TCM=\$TCM; fi

        export META PROJ RELEASE OLD_RELEASE LINK TCM

        cat ${TURNOVER_FILE} | envsubst

    else

        echo "Error: could not read ${TURNOVER_FILE}"

    fi

}

function lf {

    # Get Latest File
    if [[ -z ${1} ]]; then
        find . -type f -printf "%T@ %p\n" | sort -n | cut -d' ' -f2 | tail -n1
    else
        find ${1} -type f -printf "%T@ %p\n" | sort -n | cut -d' ' -f2 | tail -n1
    fi

}

function tlf {

    LATEST_FILE=$( lf ${1} )
    tail -n300 --follow=name ${LATEST_FILE}

}

function clf {

    LATEST_FILE=$( lf ${1} )
    cat ${LATEST_FILE}

}

function vlf {

    LATEST_FILE=$( lf ${1} )
    vim ${LATEST_FILE}

}

function owner {

    si "${1}" "key"

}

function hw {

    si "${1}" "hw"

}
    
function os {

    si "${1}" "os"

}
    

function mw {

    si "${1}" "opsmaint tasks"

}

function grn {

    si "${1}" systemgrns

}

function sum {

    si "${1}" "sum"

}

function gitcheck {

    PROJECT=${1}
    REPO=$( echo ${PROJECT} | cut -d\/ -f2 )

    if [[ ! -z ${PROJECT} && ! -z ${REPO} ]]; then

        git-manage --query ${PROJECT} ${REPO}

    fi

}

function loc {

    si "${1}" loc

}

function key {

    si "${1}" key

}

function si {

    SIHOST="${1}"
    if [[ -z "${SIHOST}" ]]; then
        SIHOST=${HOSTNAME}
    fi

    servinfo -s "${SIHOST}" -g "${2}"

}

# function roles {
# 
#     CHECK_USER=${1:-${USER}}
# 
#     tai query user_roles ${CHECK_USER} -c system.label,user_to_system.role_name -f user_to_system.path="User to System" -o csv | sed 1d | sort
# 
# }

function json {

    if [[ ! -z $1 && -e $1 ]]; then 
        cat $1 | /usr/bin/json_reformat
    fi

}

function serena {

    ssq list-keys msde/prod | \grep serena | awk '{ print "printf \""$1" = \"; ssq tell msde/prod "$1 }' | ksh

}

function safe {

    print "
icompile3.croydon.ms.com:/d/d2/msde/piried
icompile1.heathrow.ms.com:/d/d2/msde/piried
icompile2.devin3.ms.com:/d/d2/msde/piried
icompile3.devin3.ms.com:/d/d2/msde/piried
icompile2.toyosu.ms.com:/d/d2/msde/piried
icompile3.toyosu.ms.com:/d/d2/msde/piried
icompile1.toyosu.ms.com:/d/d2/msde/piried
icompile5.devin1.ms.com:/d/d1/msde/piried
    "
}

function rup {

    set -A RUP_HOST $1
    ssh -t ${RUP_HOST} exec "cat /proc/loadavg | awk '{ print \"\"\$1\" \"\$2\" \"\$3 }'" 2> /dev/null

}

function dt {

    date +%Y%m%d

}

function ts {

    if [[ ! -z $1 ]]; then

        set -A DIR $1
        set -A TS $(date +%Y-%m-%d.%H%M%S.${USER})

        if [[ -d ${DIR} && -w ${DIR} ]]; then

            mkdir -p ${DIR}/${TS}

        elif [[ -e ${DIR} && -w $(pwd) ]]; then

            mkdir -p ${TS}

        elif [[ -e ${v} && -w ${v} ]]; then

            mkdir -p ${v}/${TS}

        else

            echo "Create a dir called ${TS}"

        fi

    else

        export TS=$(date +%Y%m%d.%H%M%S)
        echo ${TS}

    fi

}

function san {

    SAN_LIST="
        ny05qbas01|vmias1131347|vmias1131346|/d/ny05qbas01/d1
    "

    SAN=$(echo ${SAN_LIST} | grep ${HOSTNAME} | cut -d\| -f4)

}

function p4instance {

    # Use variable within function only
    set -A INSTANCE $1
    set -A PROID $2
    set -A CUSTOMHOME $3
    set -A P4TICKETS $4

    # Use common module if not provided
    if [[ -z ${INSTANCE} ]]; then; INSTANCE=common; fi

    echo "Loading Perforce ${INSTANCE}"

    # Set Home if provide
    if [[ ! -z ${CUSTOMHOME} ]]; then
        echo "Setting HOME to ${CUSTOMHOME}"
        export HOME=${CUSTOMHOME}
    fi

    # Remove any existing perforce modules first
    module list 2>&1 | grep -q '3rd/perforce'
    RET=$?
    while [[ ${RET} -eq 0 ]]; do
        module unload 3rd/perforce
        module list 2>&1 | grep -q '3rd/perforce'
        RET=$?
    done

    # Loads the module, unaffected by .nomodules since this is executed after login
    module load 3rd/perforce/${INSTANCE} 

    # Get P4 Config
    case ${INSTANCE} in
        test|test1|test2)
            export P4CFG=/ms/dist/etscfg/PROJ/msde-p4/dev.current/common/${P4INSTANCE}/${P4INSTANCE}/config/p4d.cfg
            export AUTOSYS_INSTANCE=DNA
            ;;
        *)
            export P4CFG=/ms/dist/etscfg/PROJ/msde-p4/prod.current/common/${P4INSTANCE}/${P4INSTANCE}/config/p4d.cfg
            export AUTOSYS_INSTANCE=PNA
            ;;
    esac

    # Load Autosys Module
    autosysInstanceR11 ${AUTOSYS_INSTANCE}

    # Set config variables if the file exists
    if [[ -e ${P4CFG} ]]; then

        # Set config
        source ${P4CFG}

    fi

    # Use default p4 client if not set
    export P4CLIENT=${P4CLIENT:-msde-piried}

    # Module loads 2013.1 version, we want 2017 version
    export PATH=//ms/dist/3rd/PROJ/perforce/2017.1.149.1634/exec:${PATH}

    # Set Prompt to Say instance
    export PS1='$(prompt "${P4PORT} (${AUTOSERV})")'


    # Finally log in
    p4 login -a 

    # Show settings
    p4 set

}

function p4test {
    p4instance test p4tstlnx 
}

function p4test1 {
    p4instance test1 p4tstlnx
}

function p4test2 {
    p4instance test2 p4tstlnx
}

function p4xxl {
    p4instance xxl p4xxl 
}

function p4prod {
    p4instance prod p4lnx3
}

function p4eai {
    p4instance eai p4lnx1 
}

function p4ied {
    p4instance ied p4lnx2
}

function p4fid {
    p4instance fid p4lnx4
}

function p4fidcredit {
    p4instance fidcredit p4lnx1
}

function p4spstrat {
    p4instance spstrat p4lnx3
}

function p4shared {
    p4instance shared p4lnx2
}

function p4su {
    p4instance "" p4su /var/tmp/p4su
}

function bkup {

    FILE=$1
    DIR=$2

    if [[ ! -z ${FILE} && -f ${FILE} ]]; then

        if [[ -d bkup ]]; then
            echo "Backup dir found"
            cp -ipv ${FILE} bkup/${FILE}.$(date -r ${FILE} +%Y%m%d.%H%M)
        else
            if [[ ! -z ${DIR} ]]; then
                echo "${DIR} found"
                BASENAME=$(basename ${FILE})
                cp -ipv ${FILE} ${DIR}/${BASENAME}.$(date -r ${FILE} +%Y%m%d.%H%M)
            else
                echo "Backing file up to current dir"
                cp -ipv ${FILE} ${FILE}.$(date -r ${FILE} +%Y%m%d.%H%M)
            fi
        fi

    fi
}

function prompt {

SUFFIX=$1

# tput Text Mode Capabilities:
# 
# tput bold     Set bold mode
# tput dim      Turn on half-bright mode
# tput smul     Begin underline mode
# tput rmul     Exit underline mode
# tput rev      Turn on reverse mode
# tput smso     Enter standout mode (bold on rxvt)
# tput rmso     Exit standout mode
# tput sgr0     Turn off all attributes

black=$(tput setaf 0)
red=$(tput setaf 1)
redbg=$(tput setab 1)
green=$(tput setaf 2)
greenbg=$(tput setab 2)
cyan=$(tput setaf 6)
yellow=$(tput setaf 3)
magenta=$(tput setaf 5)
magentabg=$(tput setab 5)
reset=$(tput sgr0)
bold=$(tput bold)
underline=$(tput smul)
reverse=$(tput rev)
standout=$(tput smso)

CELL=$( echo ${SYS_LOC} | cut -f1 -d. )

case ${SYS_ENVIRONMENT} in
    prod)
        env="${red}Production($CELL)${reset}"
        ;;
    qa)
        env="${magenta}QA($CELL)${reset}"
        ;;
    dev)
        env="${green}Development($CELL)${reset}"
        ;;
    *)
        env="${green}QA($CELL)${reset}"
        ;;
esac

print "# ! # ${env} - ${red}$(date +%Y-%m-%d)${reset} - ${cyan}!${reset} - ${yellow}$(date +%H:%M:%S)${reset} - ${green}${USER}@${HOSTNAME}:$PWD${reset} ${magenta}${SUFFIX}${reset}
\$ "

}

function getAutosysJobOwner {

    # Get Job
    JOB=$1

    # Set Owners file
    OWNERS=~piried/etc/owners.txt

    # Get Job Owner
    OWNER=$(autorep -qj ${JOB} -l0 | awk -F'[@ ]' '{ if($1 ~ "owner:") print $2 }')

    if [[ $? -gt 0 ]]; then
        echo "Error: unable to get proid from ${JOB}" > /dev/stderr
    else

#         echo "${JOB} has owner ${OWNER}" > /dev/stderr

        # Add Job details to file
        echo "${OWNER}|${AUTOSERV}|${JOB}" >> ${OWNERS}

        if [[ $? -gt 0 ]]; then
            echo "Error: unable to add owner to the ${OWNERS} file"
        fi

        # Return Job Owner
        echo "${OWNER}"

    fi

}

function autosysAction {

ACTION=$1
JOB=$2
PROID=$3

# Source of jobs and owners
OWNERS=~piried/etc/owners.txt

# Set Machine as current host
MACHINE=${HOSTNAME}

if [[ ! -e ${OWNERS} ]]; then 
    echo "Error: cannot access ${OWNERS} file"
    exit 1
fi

if [[ -e ${OWNERS} && ! -z ${AUTOSERV} ]]; then

    # Identify Owner from List
    OWNER=$(awk -vJ=$JOB -vA=${AUTOSERV} -F\| {' if ($3==J && $2==A) print $1 '} ${OWNERS})

    if [[ -z ${OWNER} ]]; then
        OWNER=$(getAutosysJobOwner ${JOB})
    fi

    # If still empty try getting details from file
    if [[ -z ${OWNER} && -e ${JOB} ]]; then

        # Get details from file
        OWNER=$( awk {' if($1=="owner:") print $2 '} ${JOB} )

    fi

    # Instance
    AUTOSYS_INSTANCE=$(awk -vJ=$JOB -vA=${AUTOSERV} -F\| {' if ($3==J && $2==A) print $2'} ${OWNERS})

    # Execute Action
    if [[ ! -z ${OWNER} ]]; then

        case ${ACTION} in 
            CHANGE_OWNER)
                echo as_chownmach -j ${JOB} -m ${MACHINE} --owner=${OWNER}
                as_chownmach -j ${JOB} -m ${MACHINE} --owner=${OWNER}
                ;;
            SUCCESS)
                echo sendevent -j ${JOB} -e CHANGE_STATUS -s ${ACTION} --owner=${OWNER}
                sendevent -j ${JOB} -e CHANGE_STATUS -s ${ACTION} --owner=${OWNER}
                ;;
            JOB_ON_ICE|JOB_ON_HOLD|JOB_OFF_ICE|JOB_OFF_HOLD|FORCE_STARTJOB|KILLJOB)
                echo sendevent -j ${JOB} -e ${ACTION} --owner=${OWNER} 
                sendevent -j ${JOB} -e ${ACTION} --owner=${OWNER}
                ;;
            CHANGE_MACHINE)
                echo as_chownmach -j ${JOB} -m ${HOSTNAME} --owner=${OWNER}
                as_chownmach -j ${JOB} -m ${HOSTNAME} --owner=${OWNER}
                ;;
            INSERT_JIL)
                if [[ -e ${JOB} && ! -z ${TCM} && ! -z ${CMRS} ]]; then
                    echo "jil --owner=${OWNER} --tcm=${TCM} --cmrs=${CMRS} < ${JOB}"
                    jil --owner=${OWNER} --tcm=${TCM} --cmrs=${CMRS} < ${JOB}
                elif [[ -e ${JOB} && ! -z ${TCM} ]]; then
                    echo "jil --owner=${OWNER} --tcm=${TCM} < ${JOB}"
                    jil --owner=${OWNER} --tcm=${TCM}  < ${JOB}
                elif [[ -e ${JOB} ]]; then
                    echo "jil --owner=${OWNER} < ${JOB}"
                    jil --owner=${OWNER} < ${JOB}
                elif [[ -e ${JOB}.jil && ! -z ${TCM} ]]; then
                    echo "jil --owner=${OWNER} --tcm=${TCM} < ${JOB}.jil"
                    jil --owner=${OWNER} --tcm=${TCM} < ${JOB}.jil
                elif [[ -e ${JOB}.jil ]]; then
                    echo "jil --owner=${OWNER} < ${JOB}.jil"
                    jil --owner=${OWNER} < ${JOB}.jil
                else
                    echo "Could not find ${JOB} or ${JOB}.jil"
                fi
                ;;
            *)
                echo "Please confirm action (${ACTION})"
                ;;
        esac

    else

        echo "Please confirm owner (${OWNER}) and action (${ACTION})"

    fi

else

    echo "Could not load ${OWNERS} or \$AUTOSERV is not set, please run \"module 3rd/autosys/NYQ\" or similar to set"

fi


}

function co {

    JOB=$1
    autosysAction CHANGE_OWNER ${JOB}

}

function ji {

    JOB=$1
    autosysAction INSERT_JIL ${JOB}

}

function sjs {

    JOB=$1
    autosysAction SUCCESS ${JOB}

}

function al {

    JOB=$1
    autosyslog -j ${JOB}

}

function fsj {

    JOB=$1
    autosysAction FORCE_STARTJOB ${JOB} 

}

function cm {

    JOB=$1
    autosysAction CHANGE_MACHINE ${JOB} 

}

function kj {

    JOB=$1
    autosysAction KILLJOB ${JOB} 

}

function joh {

    JOB=$1
    autosysAction JOB_ON_HOLD ${JOB} 

}

function joffh {

    JOB=$1
    autosysAction JOB_OFF_HOLD ${JOB} 

}

function joi {

    JOB=$1
    autosysAction JOB_ON_ICE ${JOB} 

}

function joffi {

    JOB=$1
    autosysAction JOB_OFF_ICE ${JOB} 

}

function jrh {
#     alias JRH='jobrunhist -j'
#     alias jrh='jobrunhist -j'
    # jrh msdeops-p4-fidc-maintbndl -from '2018-06-01' -to '2018-09-01'

    JOB=$1
    FROM=$(date -d'120 days ago' +%Y-%m-%d)
    TO=$(date -d'+1 day' +%Y-%m-%d)

    echo "jobrunhist -j ${JOB} -from ${FROM} -to ${TO}"
    jobrunhist -j ${JOB} -from ${FROM} -to ${TO}

}

function also {
    # autosys log standard out
    JOB=$1
    echo "autosyslog -j ${JOB} -t O"
    autosyslog -j ${JOB} -t O
}

function alse {
    # autosys log standard error
    JOB=$1
    echo "autosyslog -j ${JOB} -t E"
    autosyslog -j ${JOB} -t E
}

function als {
    # autosys log spool file
    JOB=$1
    echo "autosyslog -j ${JOB} -t S"
    autosyslog -j ${JOB} -t S
}

# Autosys R11 Dev
function inst {
    autosysInstanceR11 INST
}

function dna {
    autosysInstanceR11 DNA
}

function dnb {
    autosysInstanceR11 DNB
}

function dnc {
    autosysInstanceR11 DNC
}

function dnd {
    autosysInstanceR11 DND
}

function dne {
    autosysInstanceR11 DNE
}

function dnf {
    autosysInstanceR11 DNF
}

function dng {
    autosysInstanceR11 DNG
}

function dnm {
    autosysInstanceR11 DNM
}

# Autosys R11 QA
function qna {
    autosysInstanceR11 QNA
}

function qnb {
    autosysInstanceR11 QNB
}

function qnc {
    autosysInstanceR11 QNC
}

function qnd {
    autosysInstanceR11 QND
}

function qne {
    autosysInstanceR11 QNE
}

function qnf {
    autosysInstanceR11 QNF
}

function qng {
    autosysInstanceR11 QNG
}

function qnm {
    autosysInstanceR11 QNM
}

# Autosys R11 Prod
function pna {
    autosysInstanceR11 PNA
}

function pnb {
    autosysInstanceR11 PNB
}

function pnc {
    autosysInstanceR11 PNC
}

function pnd {
    autosysInstanceR11 PND
}

function pne {
    autosysInstanceR11 PNE
}

function pnf {
    autosysInstanceR11 PNF
}

function png {
    autosysInstanceR11 PNG
}

function pnm {
    autosysInstanceR11 PNM
}

function dla {
    autosysInstanceR11 DLA
}

function autosysInstanceR11 {

    AUTOSYS_INSTANCE=$1
    COLOUR=$2

    if [[ ! -z ${AUTOSYS_INSTANCE} ]]; then

        # Remove any existing modules
        module unload jobsched 2> /dev/null

        # Load new module
        module load jobsched/${AUTOSYS_INSTANCE} 2> /dev/null

        if [[ $? -gt 0 ]]; then
            print "Error: could not load jobsched/${AUTOSYS_INSTANCE}"
        fi

        # Set Prompt
        export PS1='$(prompt ${AUTOSYS_INSTANCE})'

    fi

}

function environ {

    ENVIRON_FILE=/proc/${1}/environ

    if [[ -e ${ENVIRON_FILE} ]]; then

        xargs -n1 -0 < ${ENVIRON_FILE} | sort

    fi

}

function autosys {

    AUTOSYS=~piried/etc/autosys.txt

    if [[ -e ${AUTOSYS} ]]; then

        cat ${AUTOSYS}

    fi

}

function perforce {

    PERFORCE=~piried/etc/perforce.txt

    if [[ -e ${PERFORCE} ]]; then

        cat ${PERFORCE}

    fi

}


function snapshot {

    top -bm | sed '1,5d' snapshot.txt | sort -k3 | \
        awk '{ if ($3!="root" && $3!="zabbix" && $3!="rtduser" && $3!="pdistcc" && $3!="zabbix" && $3!="perfdata" && $3!="nobody" && $3!="postfix" && $3!="rtduser" && $3!="ppadm" && $3!="charladm" && $3!="quagga" && $3!="daemon" && $3!="ntp") print $0 }'

    #^$USER|^root|^pdistcc|^zabbix|^perfdata|^nobody|^postfix|^rtkit|^rtduser|^msntp|^smmsp|^gdm|^webauthd|^rpc|^dbus|^ppadm|^uuidd|^68|^charladm|^xfs|^avahi|^cimsrvr|^quagga|^daemon|^ntp|^kiwa

}

function cpu {

    CPUFILE=/proc/cpuinfo
    test -f $CPUFILE || exit 1
    NUMPHY=`grep "physical id" $CPUFILE | sort -u | wc -l`
    NUMLOG=`grep "processor" $CPUFILE | wc -l`
    NUMCORE=`grep "core id" $CPUFILE | sort -u | wc -l`
    CACHE_SIZE=$(grep "cache size" $CPUFILE | sort -u | cut -d : -f 2- | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/  */ /g' )
    CPU_MODEL=$(grep "model name" $CPUFILE | sort -u | cut -d : -f 2- | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/  */ /g' )

    echo
    if [[ $1 == "" ]]; then

        printf "The CPU is an ${CPU_MODEL} with ${CACHE_SIZE} cache\n"

        if [ $NUMPHY -eq 1 ]; then

            printf "This system has one physical CPU"

        else

            printf "This system has $NUMPHY physical CPUs"

        fi

        if [ $NUMLOG -gt 1 ]; then

            printf " and $NUMLOG logical CPUs.\n"

            if [ $NUMCORE -gt 1 ]; then

                printf "For every physical CPU there are $NUMCORE cores.  "

            fi

            printf "\n"

        else

            printf " and one logical CPU.\n"

        fi


    else

        printf "${NUMPHY},${NUMLOG},${NUMCORE},${CACHE_SIZE},${CPU_MODEL}\n"

    fi

    echo
    awk '{ printf "Load Averages     (1m, 5m, 15m) : %.2f%, %.2f%, %.2f%\n", $1, $2, $3 }' /proc/loadavg
    awk -vNUMLOG=${NUMLOG} '{ printf "CPU Load Averages (1m, 5m, 15m) : %.2f%, %.2f%, %.2f%\n", $1/NUMLOG, $2/NUMLOG, $3/NUMLOG }' /proc/loadavg
    echo



}

function d {

    DIR=$1

    if [[ -z ${DIR} ]]; then
        DIR=$(pwd)
    fi

    cd $(dirname ${DIR})

}

function oz {

if [[ ! -z ${TMUX_PANE} ]]; then

    while [[ ! -z ${1} ]]; do

        # Set default instance count
        TMUX_INSTANCES=1

        case ${1} in
            *[!0-9]*)
                #                 echo "${1}: Alphanumeric"
                HOST=${1}
                ;;
            *)
                #                 echo "${1}: Numeric"
                TMUX_INSTANCES=${1}
                ;;
        esac

        # If ${HOST} set, open 1 session, if ${INSTANCE} is a number, then we open ${INSTANCE}-1 sessions to the same host
        #         print "Host: ${HOST}"
        #         print "TMUX_INSTANCES: ${TMUX_INSTANCES}"

#         print "TMUX_INSTANCES: ${TMUX_INSTANCES}"
#         print "Host     : ${HOST}"

        SSH="ssh -Y -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=2 -o ServerAliveCountMax=2"

        if [[ ${TMUX_INSTANCES} -eq 1 ]]; then

            # Open one instance
            echo "${TMUX_BIN} new-window -d -n \"${HOST}\" \"${SSH} ${HOST}\""
            ${TMUX_BIN} new-window -d -n "${HOST}" "${SSH} ${HOST}"

        else

            # Loop through $TMUX_INSTANCES count
            for i in $(seq 2 ${TMUX_INSTANCES}); do

                echo "${TMUX_BIN} new-window -d -n \"${HOST}\" \"${SSH} ${HOST}\""
                ${TMUX_BIN} new-window -d -n "${HOST}" "${SSH} ${HOST}"

            done
        fi

        shift

    done

fi

}

function o {

if [[ ! -z ${TMUX_PANE} ]]; then

    while [[ ! -z ${1} ]]; do

        # Set default instance count
        TMUX_INSTANCES=1

        case ${1} in
            *[!0-9]*)
                #                 echo "${1}: Alphanumeric"
                HOST=${1}
                ;;
            *)
                #                 echo "${1}: Numeric"
                TMUX_INSTANCES=${1}
                ;;
        esac

        # If ${HOST} set, open 1 session, if ${INSTANCE} is a number, then we open ${INSTANCE}-1 sessions to the same host
        #         print "Host: ${HOST}"
        #         print "TMUX_INSTANCES: ${TMUX_INSTANCES}"

#         print "TMUX_INSTANCES: ${TMUX_INSTANCES}"
#         print "Host     : ${HOST}"

        SSH="ssh -Y -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=2 -o ServerAliveCountMax=2"

        if [[ ${TMUX_INSTANCES} -eq 1 ]]; then

            # Open one instance
            echo "${TMUX_BIN} new-window -d -n \"${HOST}\" \"${SSH} ${HOST}\""
            ${TMUX_BIN} new-window -d -n "${HOST}" "${SSH} ${HOST}"

        else

            # Loop through $TMUX_INSTANCES count
            for i in $(seq 2 ${TMUX_INSTANCES}); do

                echo "${TMUX_BIN} new-window -d -n \"${HOST}\" \"${SSH} ${HOST}\""
                ${TMUX_BIN} new-window -d -n "${HOST}" "${SSH} ${HOST}"

            done
        fi

        shift

    done

fi

}

function p4hosts {

    SSH="ssh -Y -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=2 -o ServerAliveCountMax=2"

    case $1 in 
        hk)
            ${TMUX_BIN} new-window -d -n "p4prod-hk" "${SSH} p4prod-hk"
            ${TMUX_BIN} new-window -d -n "p4eai-hk" "${SSH} p4eai-hk"
            ${TMUX_BIN} new-window -d -n "p4ied-hk" "${SSH} p4ied-hk"
            ${TMUX_BIN} new-window -d -n "p4fid-hk" "${SSH} p4fid-hk"
            ${TMUX_BIN} new-window -d -n "p4fidcredit-hk" "${SSH} p4fidcredit-hk"
            ${TMUX_BIN} new-window -d -n "p4spstrat-hk" "${SSH} p4spstrat-hk"
            ${TMUX_BIN} new-window -d -n "p4shared-hk" "${SSH} p4shared-hk"
            ${TMUX_BIN} new-window -d -n "p4xxl-hk" "${SSH} p4xxl-hk"
            ;;
        ny|*)
            ${TMUX_BIN} new-window -d -n "util" "${SSH} hz850c1n5"
            ${TMUX_BIN} new-window -d -n "prod" "${SSH} rr850c1n5"
            ${TMUX_BIN} new-window -d -n "eai/ied" "${SSH} hz850c1n5"
            ${TMUX_BIN} new-window -d -n "fidc/spst/shrd/xxl" "${SSH} rr851c1n1"
            ${TMUX_BIN} new-window -d -n "fid" "${SSH} hz851c1n1"
    esac

}


function o1 {

if [[ ! -z ${TMUX} ]]; then

    OHOST=${1}
    COUNT=${2:-1}
    PORT=${3}

    case ${OHOST} in
        [0-9])
            for i in $(seq 1 ${OHOST}); do

                tmux new-window -d
                if [[ $? -gt 0 ]]; then
                    break
                fi

            done
            ;;
        *)
            for i in $(seq 1 ${COUNT}); do

                if [[ -z ${3} ]]; then
                    tmux new-window -d -n "$1" "ssh -q ${1}" > /dev/null 2> /dev/null
                else
                    tmux new-window -d -n "$1" "ssh -q ${1} -p ${3}" > /dev/null 2> /dev/null
                fi

                if [[ $? -gt 0 ]]; then
                    break
                fi

            done
            ;;
    esac

else

    echo "Tmux not detected"

fi

}

function c {

    echo "$*" | bc -l

}

function n {

if [[ ! -z $1 ]]; then
    printf "\033k${1}\033\\"
else
    printf "\033k${USER}@${HOSTNAME}\033\\"
fi

}

function GetPWD {

echo ${PWD}

}

function f {

APP=${1}
FOLDERS=~piried/etc/folders.txt

if [[ -e ${FOLDERS} && ! -z ${APP} ]]; then

    print "Using ${FOLDERS}"
    awk -v KEY=${APP} -v HOST=${HOSTNAME} -F':' '{ if ( $1==KEY && ( $3==HOST || $3=="" ) ) print $2 }' ${FOLDERS} | sort | awk '{ print NR" "$1 }'

    print "Which folder do you require? "
    read -n1 -A KEY_PRESS
    echo

    KEY=`echo ${KEY_PRESS} | tr -cd '[0-9]'`

    DIR=`awk -v KEY=${APP} -v HOST=${HOSTNAME} -F':' '{ if ( $1==KEY && ( $3==HOST || $3=="" ) ) print $2 }' ${FOLDERS} | sort | awk -v KEY=${KEY} -F':' '{ if ( NR==KEY) print $1 }'`

    if [[ ! -z ${DIR} ]]; then

        if [[ -z ${MACHINE} || ${MACHINE} == ${HOSTNAME} ]]; then

            cd ${DIR}

        fi

    fi

elif [[ -e ${FOLDERS} ]]; then 

    FOLDER_DIRS=$(awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY || $2==KEY ) print $3 }' ${FOLDERS})

    if [[ -z ${FOLDER_DIRS} ]]; then

        cat ${FOLDERS}

    else

        # Convert to array
        set -A dirArray ${FOLDER_DIRS}

        # Check if we have one entry
        if [[ ${#dirArray[*]} -eq 1 ]]; then

            echo "Changing to ${FOLDER_DIRS}"
            cd "${FOLDER_DIRS}"

        else

            awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY || $2==KEY ) print $0 }' ${FOLDERS} | sort | awk -F\| '{ print NR". "$3 }'

            print "Which folder do you require? "
            read -n1 -A KEY_PRESS
            echo

            CHOSEN=`echo ${KEY_PRESS} | tr -cd '[0-9]'`
            DIR=$(awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY || $2==KEY ) print $0 }' ${FOLDERS} | sort | awk -F\| '{ print NR"|"$0 }' | awk -vKEY=${CHOSEN} -F\| '{ if($1==KEY) print $4 }')

            if [[ ! -z ${DIR} && -e ${DIR} ]]; then

                cd ${DIR}

            fi


        fi

    fi

fi

}

function msdelm {
f "msdelm"
}

function grok {
f "grok"
}

function compile {

    FILE=/v/campus/ny/appl/msde/train/data/services/taidb/System-Owns-Server.639.prod.dat
    sed 's/"//g' $FILE | sed '1d' | awk -F',' {' printf ("%-7s %10s %-14s %10s %6sGB %30s\n", $6, $7, $4, $8, $14/1024, $3) '} | sort

}

function b { # Build / Release / Dist

NAME=$1
TRAIN_INFO=~piried/etc/train.txt

if [[ -e ${TRAIN_INFO} ]]; then

    if [[ ! -z ${NAME} ]]; then

        TRAIN_COMMANDS=$(awk -vKEY=${NAME} -F\| '{ if ( $1==KEY ) print $2 }' ${TRAIN_INFO})

        if [[ -z ${TRAIN_COMMANDS} || -z ${NAME} ]]; then

            awk -F\| '{ print $1 }' ${TRAIN_INFO} | sort

        else

            echo "${TRAIN_COMMANDS}" | sort

        fi

    else

        OLDIFS=${IFS}
        IFS="/"
        DIR=$(pwd)
        for D in ${DIR}; do

            # Reset Field Separator, affects the file handling of awk
            IFS=${OLDIFS}

            TRAIN_COMMANDS=$(awk -vKEY=${D} -F\| '{ if ( $1==KEY ) print $2 }' ${TRAIN_INFO})
            if [[ ! -z ${TRAIN_COMMANDS} ]]; then
                echo ${TRAIN_COMMANDS}
                break
            fi

        done

        # Reset Field Separator
        IFS=${OLDIFS}
    fi

else

    echo "Error: could not access ${TRAIN_INFO}"

fi


}


function z {

ZAPPLETS=~/etc/zapplets.txt

if [[ ! -e ${ZAPPLETS} && -e ~piried/etc/zapplets.txt ]]; then
    ZAPPLETS=~piried/etc/zapplets.txt
fi

# Add Zapplets if dir provided
if [[ ! -z $1 && -d $1 ]]; then

    if [[ $(grep -c '^$1$' ${ZAPPLETS} ) -eq 0 ]]; then

        echo "${HOSTNAME}|$1" >> ${ZAPPLETS}

    fi

fi

if [[ -e ${ZAPPLETS} ]]; then

    ZAPPLET_DIRS=$(awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY ) print $2 }' ${ZAPPLETS})

    if [[ -z ${ZAPPLET_DIRS} ]]; then

        cat ${ZAPPLETS}

    else

        # Convert to array
        set -A dirArray ${ZAPPLET_DIRS}

        # Check if we have one entry
        if [[ ${#dirArray[*]} -eq 1 ]]; then

            echo "Changing to ${ZAPPLET_DIRS}"
            cd "${ZAPPLET_DIRS}"

        else

            awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY ) print $0 }' ${ZAPPLETS} | sort | awk -F\| '{ print NR". "$2 }'

            print "Which folder do you require? "
            read -n2 -A KEY_PRESS
            echo

            CHOSEN=`echo ${KEY_PRESS} | tr -cd '[0-9]'`
            DIR=$(awk -vKEY=${HOSTNAME} -F\| '{ if ( $1==KEY || $2==KEY ) print $0 }' ${ZAPPLETS} | sort | awk -F\| '{ print NR"|"$0 }' | awk -vKEY=${CHOSEN} -F\| '{ if($1==KEY) print $3 }')

            if [[ ! -z ${DIR} && -e ${DIR} ]]; then

                cd ${DIR}

            fi


        fi

    fi

fi

}

function nfs {

NFS=~piried/etc/nfs.txt

if [[ -e ${NFS} ]]; then

    print "Checking ${NFS} for ${SYS_COUNTRY} or ${HOSTNAME} ..."
    sort ${NFS} | awk -vKEY=${SYS_COUNTRY} -F: '{ if ( $1==KEY || $1=="*" ) print NR" "$2 }'

    print "Which folder do you require? "
    read -n2 -A KEY_PRESS
    echo

    CHOSEN=`echo ${KEY_PRESS} | tr -cd '[0-9]'`
    DIR=`sort ${NFS} | awk -vKEY=${SYS_COUNTRY} -F: '{ if ( $1==KEY ) print NR" "$2 }' | awk -vKEY=${CHOSEN} {' if ( $1==KEY ) print $2 '}`

    if [[ ! -z ${DIR} && -e ${DIR} ]]; then

        cd ${DIR}

    fi


fi

}

function stashdp {

    export STASHHOST=ivapp1254212.devin3.ms.com
    export STASHHOME=/d/d1/stashdp
    export HOME=/var/tmp/${USER}

    echo "Hostname: ${HOSTNAME}"
    echo "StashHost: ${STASHHOST}"

    # Set Aliases
    alias stashhome="cd ${STASHHOME}"

}

### End of Functions
##################################################################################

##################################################################################
### Aliases

alias p4read="if [[ -e ${P4READ} ]]; then; cd /v/region/na/appl/msde/p4read/data/prod; else echo ${P4READ} not accessible; fi"
alias p4su="if [[ -e ${P4SU} ]]; then; cd /v/region/na/appl/msde/p4su/data/prod; else echo ${P4SU} not accessible; fi"
CPSVER='2019.05.08-1'
alias cpsold='/ms/dist/appmw/PROJ/cpscpp/${CPSVER}/exec/bin/examples/config/soapsub -a p4util:12900 -t scm'
alias cpsdev='/ms/dist/appmw/PROJ/cpscpp/${CPSVER}/exec/bin/examples/config/soapsub -a scmcps.cpsfarm-dev.ms.com:4551 -t scm -K'
alias cpsprod='/ms/dist/appmw/PROJ/cpscpp/${CPSVER}/exec/bin/examples/config/soapsub -a scmcps.cpsfarm.ms.com:6097 -t scm -K'
alias csv='column -s, -t'
alias CD='cd'
alias DJ='autorep -dj'
# alias j='autorep -w -j'
# alias J='autorep -w -j'
alias JD='job_depends -c -j'
alias QJ='autorep -qj'
alias VJ='autotrack -vJ'
alias WJ='watch -t -d -n15 autorep -w -j'
# alias age='find -type f -printf "%TY-%Tm-%Td %TH:%TM %p\n"'
alias checkconn=/ms/dist/prodperim/PROJ/checkconn/prod/bin/checkconn
alias cs='cd ${CS}'
alias curl='/ms/dist/fsf/PROJ/curl/7.60.0-0/bin/curl -s' # don't display stats
alias diff='diff -wB'
alias dj='autorep -dj'
alias fl='farmlogs -action cat -log'
alias git='git --no-pager'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpp='git pull; git push'
alias gs='git status'
alias htop='/ms/dist/fsf/PROJ/htop/1.0.3/bin/htop'
alias iconfmsde='call iconf -dtmf ,,383121# $1 $2'
alias idiots=~piried/bin/idiots.sh
alias jd='job_depends -c -j'
alias jq='/ms/dist/3rd/PROJ/jq/1.5/exec/bin/jq'
alias ld="ls -lArhH --color=always | egrep '^d'"
alias less='less -I -S'
alias ll='ls -lAh --color=always'
alias machines='clear; if [[ -e ~piried/etc/machines ]]; then; cat ~piried/etc/machines; else echo "Error: could not load ~piried/etc/machines"; fi'
alias noproxy='unset ftp_proxy; unset http_proxy; unset https_proxy'
alias ns='netstat -netpula'
alias nsgrep='netstat -na | egrep -e '
alias p1='/bin/ps uaxfwww | egrep -v -e "^$USER|^root|^pdistcc|^zabbix|^perfdata|^nobody|^postfix|^rtkit|^rtduser|^msntp|^smmsp|^gdm|^webauthd|^rpc|^dbus|^ppadm|^uuidd|^68|^charladm|^xfs|^avahi|^cimsrvr|^quagga|^daemon|^ntp|^kiwa"'
alias p4suur='suu -tR p4read'
alias p="ps auxfwww"
alias path='echo $PATH | sed "s/:/\n/g" | cat -n'
alias pico='echo Use vim'
alias ports='netstat -lpnt'
alias qj='autorep -qj'
# alias s='du -d 1 -ch . -BM | sort -n'
alias s='( du -d 1 -ch . -BM 2> /dev/null ) || ( du --max-depth 1 -BM . 2>/dev/null ) | sort -n'
alias scp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=2 -o ServerAliveCountMax=2'
alias screen='screen -d -R'
alias ssh='ssh -Y -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=2 -o ServerAliveCountMax=2'
alias ssqkeys='ssq list-keys msde/prod'
alias t='tail -n300 --follow=name'
alias v='if [[ -e $v ]]; then cd $v; else ; mkdir -p $v ; cd $v; fi'
alias vc='v; clear'
alias vj='autotrack -vJ'
alias vnc1='/ms/dist/fsf/PROJ/tightvnc/1.3.10/bin/vncserver :5 -fp /usr/share/X11/fonts/misc -geometry 1024x768'
alias vnc2='/ms/dist/fsf/PROJ/tightvnc/1.3.10/bin/vncserver :5 -fp /usr/share/X11/fonts/misc -geometry 1280x1024'
alias vnc3='/ms/dist/fsf/PROJ/tightvnc/1.3.10/bin/vncserver :5 -fp /usr/share/X11/fonts/misc -geometry 1920x1080' #Hardcoded version deliberate
alias vnc3p='/ms/dist/fsf/PROJ/tightvnc/1.3.10/bin/vncserver :5 -fp /usr/share/X11/fonts/misc -geometry 1080x1920' #Hardcoded version deliberate
alias vnckill='/ms/dist/fsf/PROJ/tightvnc/1.3.10/bin/vncserver -kill $HOST:5'
alias wj='watch -t -d -n15 autorep -w -j'
alias xml='/usr/bin/xmllint --format '

### End of Aliases
##################################################################################

# Make "less" understand colours
export LESS=-R
unset LESSOPEN # Seems to cause issues with less

##################################################################################
### Sort out keybindings for end and home etc

# Example from page 98
function keybind # key [action]
{
    typeset key=$(print -f "%q" "$2")
    case $# in
        2)      Keytable[$1]=' .sh.edchar=${.sh.edmode}'"$key"
            ;;
        1)      unset Keytable[$1]
            ;;
        *)      print -u2 "Usage: $0 key [action]"
            return 2 # usage errors return 2 by default
            ;;
    esac
}


# Don't use typeset on SunOS
if [[ ${SUNOS} -eq 0 ]]; then

    typeset -A Keytable
    trap 'eval "${Keytable[${.sh.edchar}]-}"' KEYBD

    # Add Custom Key Bindings for DELETE, HOME and END

#     keybind $'\cl'   $'\e\cl'
#     keybind $'\e[1~' $'\ca'
#     keybind $'\e[2~' $'\cv'
#     keybind $'\e[3~' $'\cd'
#     keybind $'\e[4~' $'\ce'
#     keybind $'\e[5~' $'\e<'
#     keybind $'\e[6~' $'\e>'
#     keybind $'\e#'   $'\ca#\r'
#     keybind $'\cu'   $'\e0\ck'

    keybind $'\cl'   $'\e\cl'  # bash Ctrl-L (clear screen)
    keybind $'\e[1~' $'\ca'    # home (Ctrl-A)
    keybind $'\e[2~' $'\cv'    # insert literal (Ctrl-V)
    keybind $'\e[3~' $'\cd'    # delete (Ctrl-D)
    keybind $'\e[4~' $'\ce'    # end (Ctrl-E)
    keybind $'\e[5~' $'\e<'    # beginning of history (Meta-<)
    keybind $'\e[6~' $'\e>'    # end of history (Meta->)
    keybind $'\e#'   $'\ca#\r' # comment current line and return (readline compat)
    keybind $'\cu'   $'\e0\ck' # erase from point to beginning of line (readline compat)
    keybind $'\eu'   $'\ec'    # upcase current word (readline compat)
    keybind $'\ec'   $'\cc\ef' # capitalize current word (readline compat (ish))


elif [[ ${SUNOS} -eq 0 && ${RHEL4} -eq 0 ]]; then

    echo "No custom key bindings have been loaded"

fi

###
##################################################################################


##################################################################################
### Modules sorted

function modules {

# module list 2>&1 | grep -v ^C | sed 's/[0-9]\+)//g' | awk '{ for (i=1; i<=NF; i++) print $i }' | sort

export MODULE_LIST=$(module list 2>&1 | grep -v ^C | sed 's/[0-9]\+)//g' | awk '{ for (i=1; i<=NF; i++) print $i }' | sort)
echo "${MODULE_LIST}"

}

###
##################################################################################

# Set Prompt no suffix
export PS1='$(prompt)'

# Reset
set +x
