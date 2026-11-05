
# Key Differences

Feature | .data Section | .bss Section
--- | --- | ---
What it stores | Global and static variables with non-zero explicit initial values (e.g., int x = 42;). | Global and static variables that are uninitialized or explicitly initialized to zero (e.g., int y; or int z = 0;).
Storage | in binary/disk, Occupies actual space in the compiled executable file to store the initial data. | Does not occupy space for variable contents on disk; it only records a size/metadata record.
Runtime initialization | The OS/loader copies the pre-defined byte values from the executable file into RAM during startup. | The OS/loader reserves a block of RAM and zero-initializes (clears to 0) the entire block at startup.
Memory permissions | Read-Write (RW) | Read-Write (RW)
