#!/usr/bin/env python
"""./testsuite.py [options] [test name]

Run the wPOSIX testsuite
"""

from gnatpython.env import Env
from gnatpython.ex import Run
from gnatpython.fileutils import mkdir, rm
from gnatpython.main import Main
from gnatpython.mainloop import (MainLoop, add_mainloop_options,
                                 generate_collect_result)
from gnatpython.testdriver import add_run_test_options
from gnatpython.reports import ReportDiff

from glob import glob

import os
import sys

def main():
    """Run the testsuite"""
    options = __parse_options()
    env = Env()
    env.add_search_path("PYTHONPATH", os.getcwd())

    test_list = [t for t in filter_list('tests/*', options.run_test)
                 if os.path.isdir(t)]

    # Various files needed or created by the testsuite
    result_dir = options.output_dir
    results_file = result_dir + '/results'

    rm(result_dir, True)
    mkdir(result_dir)

    discs = env.discriminants

    if options.discs:
        discs += options.discs

    def test_build_cmd(test, _):
        """Run the given test"""
        cmd = [sys.executable, 'run-test',
                    '-d', ",".join(discs),
                    '--output-dir', result_dir,
                    test]
        if options.verbose:
            cmd.append('-v')
        if options.host:
            cmd.append('--host=' + options.host)
        if options.target:
            cmd.append('--target=' + options.target)
        return Run(cmd, bg=True)

    collect_result = generate_collect_result(
        result_dir, results_file, options.view_diffs)

    MainLoop(test_list, test_build_cmd, collect_result, options.mainloop_jobs)
    # Write report
    with open(result_dir + '/discs', 'w') as discs_f:
        discs_f.write(" ".join(discs))
    ReportDiff(result_dir, options.old_result_dir).txt_image(
        result_dir + '/report')

def filter_list(pattern, run_test=""):
    """Compute the list of test matching pattern

    If run_test is not null, run only tests containing run_test
    """
    test_list = glob(pattern)
    if not run_test:
        return test_list
    else:
        return [test for test in test_list if run_test in test]

def __parse_options():
    """Parse command lines options"""
    m = Main(add_targets_options=True)
    add_mainloop_options(m)
    add_run_test_options(m)
    m.add_option("--diffs", dest="view_diffs", action="store_true",
                 default=False, help="Print .diff content")
    m.add_option("--old-result-dir", type="string", default=None,
                 help="Old result dir")
    m.parse_args()

    if m.args:
        m.options.run_test = m.args[0]
        # User want to run only one test
        print "Running only test '%s'" % m.options.run_test
    else:
        m.options.run_test = ""

    if m.options.discs:
        m.options.discs = m.options.discs.split(',')

    return m.options

if __name__ == "__main__":
    try:
        main()
    except AssertionError, e:
        print 'ERROR: %s' % e
