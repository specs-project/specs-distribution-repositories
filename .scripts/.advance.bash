#!/dev/null

if ! test "${#}" -eq 0 ; then
	echo "[ee] invalid arguments; aborting!" >&2
	exit 1
fi

env -i "${_git_env[@]}" "${_git_bin}" \
		submodule foreach --quiet \
			'echo "$( pwd ) ${name} ${sha1}"' \
| while read path name sha1 ; do
	path="$( readlink -e "${name}" )"
	name="$( basename "${name}" )"
	orig_path="$( readlink -e ../.specs-repositories )/${name}"
	if test "${orig_path}" == "${path}" ; then
		continue
	fi
	if test ! -e "${orig_path}" ; then
		echo "[ww] ?? ${name}" >&2
		continue
	fi
	origin_sha1="$(
			cd "${orig_path}"
			exec env -i "${_git_env[@]}" "${_git_bin}" rev-parse HEAD
	)"
	if test "${sha1}" != "${origin_sha1}" ; then
		echo "[ww] ## ${name} -> ${origin_sha1}" >&2
		(
			cd "${path}"
			exec env -i "${_git_env[@]}" "${_git_bin}" fetch
		)
		if (
				cd "${path}"
				exec env -i "${_git_env[@]}" "${_git_bin}" cat-file -e "${origin_sha1}"
		) ; then (
				cd "${path}"
				exec env -i "${_git_env[@]}" "${_git_bin}" checkout "${origin_sha1}"
		) ; else
			echo "[ee] #### !!!!" >&2
		fi
	else
		echo "[ii] -- ${name}" >&2
	fi
done

exit 0
