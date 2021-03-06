# Once-only design document

The design and implementation of once-only is pretty straightforward.
Try reading the source code in ./bin/once-only and the files in ./lib

With this tool I adhered to a functional programming style. There are 
no classes maintaining state, only functions. All functions use explicit
parameters and return values, usually using Hashes or simple primitives 
as return values.

# Parsing the command line

The command line is parsed for file names. If a file exists it is added to the
check list, unless it is listed with the --exclude switch. Files can be
explicitly added with the --include switch.

# Parsing the command line with PBS

For PBS the command line is stripped of PBS command and added to the queue.

# Pre-calculated hash values

When a hash file is given with --precalc the contained hashes are not recalculated.

If the hash file is older than the target file an error is given.

# Locking

Before starting a specific run, a lock file is created with the extension .lock.

We check for an existing lock first, unless --ignore-lock or --force is used.

When the lock exists and is older than 6 hours it is considered stale and ignored.

After completing the run, the lock is removed.

# Checking output

If there is a possibility that output files change after running jobs
it may be an idea to build an explicit list of output files with
MD5/pfff values and have those checked. I sometimes remove intermediate files,
which alarms once-only as it looks for non-existent input files further along in
the pipeline.

When a job completes the command line can possibly be parsed again for output
files (files that appeared) and switches can be added. The --skip lists are
obvious candidates for output too.  Basically, in addition to the xxxx-SHA.txt
file we can add xxxx-SHA.out.txt. If it exists, use it.

As it stands the output files can be added to the input file, as long as
the SHA is calculated over the inputs only.

# Running



