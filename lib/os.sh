detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "unsupported"
      fi
      ;;
    *) echo "unsupported" ;;
  esac
}

OS=$(detect_os)
export OS
