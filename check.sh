#!/bin/bash
# dotfiles/check.sh

# check.sh
# 	Find shell scripts then run shellcheck 
# 	Adapted from jessfraz/dotfiles/bin/test.sh
# 	https://github.com/jessfraz/dotfiles/blob/master/test.sh

# 	Thank you to 0xmachos for the following code. I promise it will change eventually

set -euo pipefail
# -e exit if any command returns non-zero status code
# -u prevent using undefined variables
# -o pipefail force pipelines to fail on first non-zero status code


FAIL="\\033[1;31mFAIL\\033[0m"
INFO="\\033[1;36mINFO\\033[0m"
PASS="\\033[1;32mPASS\\033[0m"


check_shellcheck () {

	if ! [ -x "$(command -v shellcheck)" ]; then 
		echo -e "[${FAIL}] shellcheck not installed"
		echo -e "[${INFO}] macOS: brew install shellcheck"
		echo -e "[${INFO}] Linux: apt install shellcheck"
		exit 1
	fi
}


lint_shell_files () {

	for f in $(find . -type f -not -iwholename '*.git*' \
				-not -iwholename '*venv*' \
				| sort -u); do
		# Find all regular files in source directory

		if file "${f}" | grep --quiet "shell" ; then
			# Find shell files
			
			if shellcheck "${f}" ; then
				# Run shellcheck on the file
				echo -e "[${PASS}] Sucessfully linted ${f}"
			else
				echo -e "[${FAIL}] Failed to lint ${f}"
				ERRORS+=("${f}")
				# If shellcheck fails add failing file name to array
			fi
		
		elif file "${f}" | grep --quiet "bash" ; then
			# Find shell files
			# Running file on a script with the shebang "#!/usr/bin/env ..." returns
			# "a /usr/bin/env bash script, ASCII text executable" rather than
			# "Bourne-Again shell script, ASCII text executable"
			
			if shellcheck "${f}" ; then
				# Run shellcheck on the file
				echo -e "[${PASS}] Sucessfully linted ${f}"
			else
				echo -e "[${FAIL}] Failed to lint ${f}"
				ERRORS+=("${f}")
				# If shellcheck fails add failing file name to array
			fi
		fi
	done
}


main () {

	ERRORS=()

	check_shellcheck
	lint_shell_files

	if [ ${#ERRORS[@]} -eq 0 ]; then
		# If ERRORS empty then 
		echo -e "[${PASS}] No errors, hooray"
		exit 0
	else
		# If errors print the names of files which failed
		echo -e "[${FAIL}] These files failed linting: ${ERRORS[*]}"
		exit 1
	fi
}

main "$@"
