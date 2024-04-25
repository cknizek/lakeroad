#!/bin/sh
# This script exports a number of variables that help to pin the versions of
# various Lakeroad dependencies.
#
# To use, source this script before running relevant commands e.g. in a
# Dockerfile.
#
# This is just one possible way to implement dependency tracking. Some of the
# other options are:
# - No tracking at all. E.g. in the Dockerfile, we could clone STP at a specific
#   commit, using a "magic constant" commit hash. This isn't ideal, because if
#   we use STP elsewhere (e.g. in the evaluation) we have to make sure we keep
#   the commit hashes in sync.
# - Git submodules. This is very similar to what we've chosen to do, but it's
#   more directly supported by Git. For example, we used to have Bitwuzla be a
#   submodule of Lakeroad. This avoids the need to sync commit hashes as in the
#   first option. However, it's a bit overkill to add a full repository as a
#   submodule when we only need the resulting binary.
#
# This option is essentially a lighter-weight version of submodules. We track
# the commit hashes of the dependencies we need, but nothing additional is
# cloned on a `git clone --recursive`.

# TODO(@gussmith23): switch back to mainline stp when https://github.com/stp/stp/pull/482 merged
export STP_USER_AND_REPO="gussmith23/stp"
export STP_COMMIT_HASH="4570d4e8671cd8e4ee872b9a4bdc8bc48a690457"
export YICES2_COMMIT_HASH="5326f0d645df6e38ae6e7d944381d01ba7d805ab"
export BITWUZLA_COMMIT_HASH="b655bc0cde570258367bf8f09a113bc7b95e46e9"
export RACKET_FMT_COMMIT_HASH="7d0a3dfff3a6cacfb59972a56d476556f89a0b1b"
export YOSYS_COMMIT_HASH="70d35314dbd7521870047ed607897f22dc48cbc3"
export CVC5_COMMIT_HASH="ebfdf84d5698eeb83e0fa4e45101fe4a8f4543eb"
export VERILATOR_COMMIT_HASH="881c6ee6557fbde017466553b2f0918250e9c4bd"
