# Configuration Manager Site Role Baselines

Here you will find an export of Configuration Items, and Configuration Baselines that will assist with configuring various Configuration Manager Site System roles.

If a CI has "(Define Variable)" or other things inside parenthesis in the name, this means you need to open up the script and define a variable to work for your environment, or adjust a CI. Don't forget to edit both the detection, and the remediation if applicable!

I will try to add to the Readme with any notes regarding these, but wanted to at least get them up here!

### Configuration Baselines
* **ConfigMgr: _ALL (For Import Export)**
  * Strictly used for importing, and exporting all the CIs and CBs. This should not be deployed
*  ConfigMgr: Distribution Point
  * IIS log cleanup and configuration
  * Ensure IIS service is running, and DP app pool is running
  * Automatic deduplication configuration
  * Automatic PXE firewall rule setup if PXE enabled services found
  * Windows feature install for DP role
  * HTTP and SMB firewall rules
* **ConfigMgr: Fallback Status Point**
  * IIS log cleanup and configuration
  * Ensure IIS service is running, and FSP app fool is running
  * HTTP firewall rule
  * Windows feature install for FSP role
* **ConfigMgr: Management Point**
  * IIS log cleanup and configuration
  * Ensure IIS service is running, and MP app pool is running
  * Windows feature install for MP role
  * HTTP and SMB firewall rules
  * MP Logging Configuration
    * Ensure you adjust the log directory to match your environment
    * Note that this enables SQL logging on the MP, and verbose, as well as some large log file size limits. Adjust as needed.
* **ConfigMgr: Management Point HTTPS**
  * SSL cert binding CI, adjust variable for your autoenrollment CA. 
    * Could likely make this have a application script, and not need an additioanl CI, like how WSUS is handled.
* **ConfigMgr: Reporting Services Point**
  * Ensure Reporting Services Service is running
* **ConfigMgr: Site Database**
  * Ensure MSSQLSERVER service is running
  * Ensure SQLSERVERAGENT service is running
  * SQL max memory set to 80% of available
    * May want to adjust to your environment
  * SQL and SMB firewall rules, check the SQL ports!!
* **ConfigMgr: Site Server**
  * Set Max Mif Size in registry to 50mb
  * Windows features for Site Server role (including WSUS Management features)
* **ConfigMgr: Site System**
  * Windows features for general site system role
    * WCF
    * NET-Framework
    * WAS
    * MSRDC
  * Ensure Remote Registry is set to Automatic startup, and running
  * Configure Archive Logging
    * Adjust directory for your environment
  * NO_SMS_ON_DRIVE.SMS
    * Adjust to specify drive to NOT have the file on. Only allows for 1 drive set.
    * Could be adjusted to have multiple drive exclusions
  * Administrator Group
    * Will auto add the specified group(s) as administrator on all site systems targeted with the CB
* **ConfigMgr: Software Update Point (SQL)**
  * IIS log cleanup and configuration
  * Ensure IIS service is running, and WSUSPool is running
  * Windows Features for WSUS SQL based role
  * Firewall rules for HTTP, SMB, and WSUS
  * LEDBAT configuration
    * Dynamically finds your WSUS ports and configures LEDBAT
  * WSUS Content Anon Auth
    * Ensures the authentication for the Content Virtual Directory is using the app pool identity (Network Service by default)
  * WSUS Content Path
    * Ensures the WSUS Content Virtual Directory Path matches what is found in the registry
    * Sometimes, especially if the content path is specified as a UNC path, IIS will stip off the leading '\\' from the path. This CI remediates this.
  * WSUS SSL Configuration
    * The SSL configurations for a SUP / WSUS is intended to configure, or fix a WSUS server that has had configuressl ran already. [WSUSUtil ConfigureSSL](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/deploy/2-configure-wsus#to-configure-ssl-on-the-wsus-root-server) sets up the WSUS instance to be ready for SSL, and then the CB can come back through and setup, or fix the configuration. 
    * The SSL Cert binding requires a variable adjustment to find a cert from your issuing CA
  * WSUS configuration
    * This is ultimately a copy (with some edits) of [Sherry Kissinger's CIs for WSUS](https://tcsmug.org/blogs/sherry-kissinger/512-wsus-administration-wsuspool-web-config-settings-enforcement-via-configuration-items)
    * May want to adjust for your env, but it is a good baseline!
* **ConfigMgr: Software Update Point (WID)**
  * Identical to SQL one above, but installs WID roles instead of SQL roles
