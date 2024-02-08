# Install based off system

# Get current dir
dir=$(dirname $0)
echo "Dir: ${dir}"

[[ $? -gt 0 ]] && echo "Error" && exit 1

# Lets See if We have a /etc/os-release, if so we will source it
if [[ -e /etc/os-release ]]; then
  source /etc/os-release

  case ${NAME} in 
    "Amazon Linux")
      echo "Using Amazon Linux"
      ;;
    *)
      echo "Unable to determine type of host"
      exit 1
      ;;
  esac

else

  # lets try and use uname
  case $(uname -s) in
    Darwin)
      echo "Using Darwin, MacOS"
      ;;
    *)
      echo "Unable to determine type of host"
      exit 1
      ;;
  esac

fi

# Generics, only hard link if not already there
[[ ! -e ~/.vimrc ]] && ln ${dir}/vim/.vimrc ~/.vimrc || echo "~/.vimrc already in place"
