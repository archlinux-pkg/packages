#!/bin/bash
# * Environmental variables
# * STAGE = Current stage that builds
# * STAGE_ARCHIVE = Stage archive name
# * BUILD_TIMEOUT = Build time timeout
# * FINISHED = Compilation been completed?

# * GitHub Runner Outputs
# * FINISHED = Compilation been completed?

cd /home/build

# ? variables
ROOT_DIR=$(pwd)
export HOME="/home/build"

# ? makepkg arguments
BUILD_ARGUMENTS="--skippgpcheck"

# ? if the compilation has been completed in previous stages
if [ "$FINISHED" = "yes" ]
then
	#  ? github actions set output FINISHED to `yes`
	echo '::set-output name=FINISHED::yes'

	exit 0
fi

# ? unpack compilation files from previous stage
unpack_stage() {
	sudo tar xf "$STAGE_ARCHIVE" -C "$ROOT_DIR"
	sudo rm -rf "$STAGE_ARCHIVE"

	 echo "==> Added --noextract --nodeps to build arguments"
	BUILD_ARGUMENTS="--noextract --nodeps"
}

# ? free space on GitHub Runner
free_space() {
	echo "::group::Free space on GitHub Runner..."

	echo "==> Deleting /usr/share/dotnet.."
	sudo rm -rf /usr/share/dotnet
	echo "==> Deleting /usr/local/lib/android.."
	sudo rm -rf /usr/local/lib/android
	echo "==> Deleting /opt/ghc.."
	sudo rm -rf /opt/ghc

	echo "::endgroup::"
}

# ? build stage with timeout
build_stage() {
	echo "::group::Building stage..."

	echo "==> Building package..."
	timeout -k 10m -s SIGTERM "$BUILD_TIMEOUT" makepkg $BUILD_ARGUMENTS

	EXIT_CODE=$?

	if [[ $EXIT_CODE == 0 ]]
	then
		echo "==> Build successful"
	elif [[ $EXIT_CODE == 124 ]] # https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html#timeout-invocation
	then
		echo "==> Build timed out"
	else
		echo "==> Build failed with $EXIT_CODE"

		exit $EXIT_CODE
	fi


	echo "::endgroup::"
}

# ? pack the stage files
pack_stage() {
	echo "::group::Packing stage..."

	echo "==> Compressing stage..."

	tar caf /home/build/stage.tar.zst src/ --remove-file -H posix --atime-preserve

	echo "::endgroup::"
}

# ? download files from previous stage
if [ "$STAGE" -gt 1 ]
then
	unpack_stage
fi

# ? fix permissions
sudo chown -R build .

free_space

build_stage

if compgen -G "*.pkg.tar.xz" > /dev/null
then
	echo "==> Successfully built package"

	# ? github actions set output FINISHED to `yes`
	echo '::set-output name=FINISHED::yes'
else
	pack_stage

	# ? github actions set output FINISHED to `no`
	echo '::set-output name=FINISHED::no'
fi
