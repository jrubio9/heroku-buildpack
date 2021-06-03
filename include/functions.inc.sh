function append_json() {
 local json="${1}" key="${2}" val="${3}"
 local sedpats=("s/(\"|\\\\)/\\\\\1/g" ":a; N; \$!ba; s/\n/\\\\n/g;s/\r//g")

 # replace newlines to \n in key and value and " to \"

 for sedpat in "${sedpats[@]}"; do
  key="$(echo "${key}" | sed -E "${sedpat}")" || return 1
  val="$(echo "${val}" | sed -E "${sedpat}")" || return 1
 done

 if [ ${#json} -gt 0 ]; then
   json="${json},
"
 fi

 echo -n "${json}  \"${key}\": \"${val}\""
}

function check_dotnet_install() {
 local cmd result nlarg

 if [ -x "${dotnet_root}/dotnet" ]; then
  cmd=("${dotnet_root}/dotnet" --version)
  result="$("${cmd[@]}" 2>&1)" || {
   if [ "${1}" != "silent" ]; then
    fail_cmd "Unable to run dotnet executable after installation" "${cmd[*]}" "${result}"
   else
    return 1
   fi
  }
 else
  if [ "${1}" != "silent" ]; then
   fail "The 'dotnet' executable couldn't be found."
  else
   return 1
  fi
 fi
}

function fail() {
 >&2 echo " ! ## Error - ${@}"
 exit 1
}

function fail_cmd() {
 local msg="${1}" cmd="${2}" output="${3}"
 local multiline_msg

 multiline_msg="Failed command and output:

\$ ${cmd}

${output}
----

${abortbuildmsg}"

 multiline_msg="$(echo "${multiline_msg}" | indent)"

 fail "${msg}.
${multiline_msg}"
}

function gbs_compile() {
 local cflags eopts=() ldflags pkdir result tarball url

 for arg in "${@}"; do
  case "${arg}" in
   --url=*) url="${arg#*=}";;
   --cflags=*) cflags="${arg#*=}";;
   --ldflags=*) ldflags="${arg#*=}";;
   --eopt=*) eopts+=("${arg#*=}");;
  esac
 done

 if [ -z "${url}" ]; then
  fail "gbs_compile: no URL specified."
 fi

 result="$(wget "${url}" 2>&1)" || \
  fail_cmd "Unable to retrieve package" "wget \"${url}\"" "${result}"

 tarball="${url##*/}"
 result="$(tar -xvf "${tarball}" 2>&1)" || \
  fail_cmd "Unable to extract package" "tar -xvf \"${tarball}\"" "${result}"

 pkdir="${tarball%.tar.*}"
 cd "${pkdir}" || fail "Unable to change to directory: "${pkdir}""
 result="$(CFLAGS="${cflags}" LDFLAGS="${ldflags}" ./configure --prefix="${usr_root}" "${eopts[@]}" 2>&1)" || \
  fail_cmd "Unable to configure package" "./configure --prefix=\"${usr_root}\"" "${result}"
 result="$(make -j${makejobs} 2>&1)" || \
  fail_cmd "Unable to compile package" "make -j${makejobs}" "${result}"
 result="$(make install 2>&1)" || \
  fail_cmd "Unable to install package" "make install" "${result}"
 cd .. || fail "Unable to change back to upper level directory."
}
# Heroku styling (https://devcenter.heroku.com/articles/buildpack-api#style)
function notice() {
 echo "       ${@}"
}

function section() {
 echo "-----> ${@}"
}

function indent() {
 sed -u "s/^/       /"
}
