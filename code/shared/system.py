# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory



def run(cmd, capture=False, **kwargs):
	"""
	Run a subprocess, defaulting to check=True and stderr captured.
	- cmd:     list = direct exec, str = shell command
	- capture: True = pipe and return stdout; auto-promoted to True if text= is in kwargs
	- returns: proc.stdout if capturing, otherwise the CompletedProcess object
	- raises:  Exception with decoded stderr (or stdout if stderr is empty and not capturing)
	"""
	kwargs.setdefault('check', True)
	kwargs.setdefault('stderr', subprocess.PIPE)
	if capture := capture or 'text' in kwargs:
		kwargs['stdout'] = subprocess.PIPE
	try:
		proc = subprocess.run(cmd, shell=isinstance(cmd, str), **kwargs)
		return proc.stdout if capture else proc
	except subprocess.CalledProcessError as e:
		errorText = e.stderr if (e.stderr or capture or not e.stdout) else e.stdout
		if isinstance(errorText, bytes):
			errorText = errorText.decode()
		raise Exception(errorText) from e


def status_text(unit:str) -> str:
	return run(['systemctl', '--no-pager', '--full', 'status', unit], True, text=True, check=False)

def restart(unit):
	run(['systemctl', '--no-block', 'restart', unit])

def stop(unit):
	run(['systemctl', '--no-block', 'stop', unit])


def reboot(kexec=True):
	run(['reboot-kexec' if kexec else 'reboot'])

def poweroff():
	run(['poweroff'])


def tar_create(directory:str, *args:str, output:str|bool=True):
	"""
	Create an xz-compressed tar archive, preserving all extended attributes.
	- directory: base directory for resolving paths in args
	- args:      files/paths to include (relative to directory)
	- output:    True  = capture and return archive bytes
	             False = stream to process stdout
	             str   = write to file path
	"""
	run_args = [
		'tar',
		'--create',
		'--xattrs',
		'--xattrs-include=*',
		'--use-compress-program=xz -T0 -4',
		f'--directory={directory}',
		*args
	]
	if isinstance(output, str):
		run_args.append(f'--file={output}')

	return run(run_args, output is True)


def gpg(*args:str, status:set[str]|None=None, input:bytes|None=None, output:str|bool=True):
	"""
	Run a GPG command in a temporary isolated homedir, using /etc/gpg/gpg.conf.
	- args:   GPG arguments (operation flags, key references, etc.)
	- input:  bytes to feed to GPG's stdin, or None to read from process stdin
	- output: True  = capture and return output bytes
	          False = stream to process stdout
	          str   = write to file path
	- status: set of strings that must all appear in GPG's stderr; raises if any are missing
	"""
	with TemporaryDirectory(prefix='gpg_') as homedir:
		run_args = [
			'gpg',
			f'--homedir={homedir}',
			'--options=/etc/gpg/gpg.conf',
			*args
		]
		if isinstance(output, str):
			run_args.append(f'--output={output}')

		proc = run(run_args, input=input, stdout=subprocess.PIPE if output is True else None)

	if status:
		stderr:str = proc.stderr.decode()
		gpg_status = {line.split()[1] for line in stderr.splitlines() if line.startswith('[GNUPG:]')}
		if not status.issubset(gpg_status):
			raise Exception(f'Unexpected gpg status: missing {status - gpg_status}')

	return proc.stdout


def virtual():
	"""
	Returns True if the system is running inside a virtual environment
	"""
	return 'hypervisor' in Path('/proc/cpuinfo').read_text()
