# Hardware / IPMI / iDRAC Notes

## Reboot IPMI from Linux:
`ipmitool mc reset cold`

## Get iDRAC IP from Linux:
`ipmitool mc getsysinfo delloem_url`

## Get Service Tag from Linux:
`dmidecode | grep -i "Serial Number" | head -n1`