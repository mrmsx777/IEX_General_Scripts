Uninstall Persistent / untagged / version corrupted strings : 
Use this tool > https://github.com/TSA-SAUSS/UninstallBloatware/tree/main
other links will be appended for this regard

# 1. Import the module from its actual path
Import-Module .\Content\Module\UninstallBloatware.psm1

# 2. Run the command to target HP Connection Optimizer
Uninstall-Bloatware -LogDirectory "C:\Temp" -BloatwaresWin32 @('HP Connection Optimizer')

# 3. Fetch and run the module directly from raw GitHub (irm | iex)
# Note: Executing code directly from the internet can be risky. Review the script before running.
# Example (uses the raw GitHub URL for the UninstallBloatware module):

# PowerShell (full cmdlet):
Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/mrmsx777/IEX_General_Scripts/main/Content/Module/UninstallBloatware.psm1' -UseBasicParsing | Invoke-Expression

# PowerShell (aliases):
irm 'https://raw.githubusercontent.com/mrmsx777/IEX_General_Scripts/main/Content/Module/UninstallBloatware.psm1' | iex
