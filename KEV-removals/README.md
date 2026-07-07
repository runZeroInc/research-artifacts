# KEV Removals

It's occasional, but it does happen. Let's find out how often. The `kev-data` CISAGov repo was created on January 27, 2025, so we don't have history from before that event.

```
./kev-removals.sh $HOME/git/todb/kev-data 
Current KEV reference: da74638721468c593fce61dd60a5decc5ef9b0b7 (2026-07-07)
Reading current KEV list...
Finding removed CVEs...
2025-06-09: CVE-2025-4664 removed (2790dea9), still absent
2025-08-15: CVE-2007-0671 removed (ea8b31c8), but present in current (git topology weirdness)
2025-08-15: CVE-2013-3893 removed (ea8b31c8), but present in current (git topology weirdness)
2025-08-15: CVE-2025-8088 removed (ea8b31c8), but present in current (git topology weirdness)
2025-08-15: CVE-2025-8875 removed (ea8b31c8), but present in current (git topology weirdness)
2025-08-15: CVE-2025-8876 removed (ea8b31c8), but present in current (git topology weirdness)
2025-08-18: CVE-2025-54948 removed (c626fed9), but present in current (git topology weirdness)
2025-10-22: CVE-2025-6264 removed (b38d1c59), still absent
```
