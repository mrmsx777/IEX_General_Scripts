Uninstall Persistent / untagged / version corrupted strings : 
Use this tool > https://github.com/TSA-SAUSS/UninstallBloatware/tree/main
other links will be appended for this regard

# 1. Import the module from its actual path
Import-Module .\Content\Module\UninstallBloatware.psm1

# 2. Run the command to target HP Connection Optimizer
Uninstall-Bloatware -LogDirectory "C:\Temp" -BloatwaresWin32 @('HP Connection Optimizer')
