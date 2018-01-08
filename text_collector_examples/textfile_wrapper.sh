#!/bin/bash
#
# Copyright 2018 The Prometheus Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description: Wrapper script to atomically write prometheus textfile script output.

set -u

usage() {
  echo "usage: $(basename $0) <collector_script> <output_file>"
  echo "NOTE: The output filename will automatically be written with a .prom extension"
}

if [[ $# != 2 ]]; then
  usage
  exit 1
fi

script="$1"
output_file="$2"
output_dir="$(dirname "${output_file}")"

if [[ ! -x "${script}" ]]; then
  echo "ERROR: Collector script '${script}' is not found or not executable."
  exit 1
fi

if [[ ! -d "${output_dir}" ]] ; then
  echo "ERROR: Invalid output directory '${output_dir}'"
  exit 1
fi

tmpfile="$(mktemp -p "${output_dir}" ".${script}.XXXXXXXX")"

if [[ $? -ne 0 || ! -w "${tmpfile}" ]]; then
  echo "ERROR: Unable to make tempfile '${tmpfile}'"
  exit 1
fi

${script} > "${tmpfile}"

mv "${tmpfile}" "${output_file}.prom"
