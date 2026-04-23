{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    mtr
    traceroute
    tcpdump
    nmap
    dnsutils # dig, nslookup
    inetutils # telnet, ping, etc.
    iperf3
    whois
  ];
}
