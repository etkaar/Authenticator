# Authenticator
Standalone authenticator executable (Windows) for internal purposes, e.g. used with a DynDNS service.

#### False Positives by Antivirus Software

AutoIt is dead easy to use; end users do not need to install AutoIt to run compiled programs. However, the downside is, that it is often wrongfully detected as a virus by Windows Defender or other antivirus software.

#### Requirements

- AutoIt 3.3.14.5
- A background service reachable over HTTPS, such as a DynDNS service while the servers firewall will periodically check the given DynDNS hostnames.

#### Example

![example](https://user-images.githubusercontent.com/40885610/130969447-05a6de95-a9c4-4faa-978c-427136cfde0c.png)
