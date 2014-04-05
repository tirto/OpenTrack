for /f "delims=, tokens=1" %%I in (%1) do net group StudentGG %%I /ADD
:exit

